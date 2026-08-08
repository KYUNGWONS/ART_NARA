# -*- coding: utf-8 -*-
"""Notion / Figma 공통 헬퍼.

Figma 렌더 URL 은 임시(S3, 만료됨)라 그대로 두면 나중에 깨진다.
그래서 이미지를 내려받아 Notion 에 업로드하고 그 파일을 블록으로 붙인다.
"""
import io, json, mimetypes, os, urllib.request, urllib.error, uuid

_CFG = json.load(io.open(
    'C:/Users/worms/OneDrive/문서/guide/.claude/settings.local.json',
    encoding='utf-8'))['env']
NOTION_TOKEN = _CFG['NOTION_TOKEN']
FIGMA_TOKEN = _CFG['FIGMA_TOKEN']


def api(method, path, body=None):
    req = urllib.request.Request('https://api.notion.com/v1' + path, method=method)
    req.add_header('Authorization', 'Bearer ' + NOTION_TOKEN)
    req.add_header('Notion-Version', '2022-06-28')
    data = None
    if body is not None:
        data = json.dumps(body, ensure_ascii=False).encode('utf-8')
        req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req, data) as r:
            text = r.read().decode('utf-8')
            return r.status, (json.loads(text) if text else {})
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode('utf-8'))
        except Exception:
            return e.code, {}


def rt(text):
    return [{'type': 'text', 'text': {'content': str(text)[:2000]}}]


# ---------- Figma ----------
def figma_image_url(file_key, node, scale=2, attempts=4):
    """프레임 PNG 렌더 URL(임시)을 받는다.

    Figma 는 연속 호출에 429 를 준다 — 점점 길게 기다리며 재시도한다.
    """
    import time
    url = ('https://api.figma.com/v1/images/%s?ids=%s&format=png&scale=%s'
           % (file_key, node, scale))
    for i in range(attempts):
        req = urllib.request.Request(url)
        req.add_header('X-Figma-Token', FIGMA_TOKEN)
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                res = json.loads(r.read().decode())
            return (res.get('images') or {}).get(node)
        except urllib.error.HTTPError as e:
            if e.code == 429 and i < attempts - 1:
                wait = 15 * (i + 1)
                print('    Figma 요청 제한 — %d초 후 재시도' % wait)
                time.sleep(wait)
                continue
            print('    Figma 렌더 실패:', e)
            return None
        except Exception as e:
            print('    Figma 렌더 실패:', e)
            return None
    return None


def download(url):
    with urllib.request.urlopen(url, timeout=180) as r:
        return r.read()


# ---------- Notion 파일 업로드 ----------
def upload_file(content, filename):
    """Notion 에 파일을 올리고 file_upload id 를 돌려준다."""
    ctype = mimetypes.guess_type(filename)[0] or 'application/octet-stream'
    st, res = api('POST', '/file_uploads',
                  {'mode': 'single_part', 'filename': filename, 'content_type': ctype})
    if st != 200:
        print('    업로드 세션 실패', st, str(res)[:150])
        return None
    upload_id, upload_url = res['id'], res['upload_url']

    boundary = '----notion' + uuid.uuid4().hex
    body = io.BytesIO()
    body.write(('--%s\r\n' % boundary).encode())
    body.write(('Content-Disposition: form-data; name="file"; filename="%s"\r\n'
                % filename).encode())
    body.write(('Content-Type: %s\r\n\r\n' % ctype).encode())
    body.write(content)
    body.write(('\r\n--%s--\r\n' % boundary).encode())

    req = urllib.request.Request(upload_url, data=body.getvalue(), method='POST')
    req.add_header('Authorization', 'Bearer ' + NOTION_TOKEN)
    req.add_header('Notion-Version', '2022-06-28')
    req.add_header('Content-Type', 'multipart/form-data; boundary=' + boundary)
    try:
        with urllib.request.urlopen(req, timeout=180) as r:
            json.loads(r.read().decode())
        return upload_id
    except urllib.error.HTTPError as e:
        print('    파일 전송 실패', e.code, e.read().decode()[:200])
        return None


def image_block(file_upload_id, caption=''):
    block = {'object': 'block', 'type': 'image',
             'image': {'type': 'file_upload',
                       'file_upload': {'id': file_upload_id}}}
    if caption:
        block['image']['caption'] = rt(caption)
    return block
