# -*- coding: utf-8 -*-
"""screens.py 를 읽어 Notion 에 'ART NARA 앱 기획 DB' 를 만들고 화면 페이지를 채운다.

여러 번 실행해도 안전하다: 화면 ID 로 기존 페이지를 찾아 있으면 갱신, 없으면 생성한다.
토큰은 git 미추적 .claude/settings.local.json 에서 읽는다.
"""
import io, json, os, sys, urllib.request, urllib.error

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from screens import SCREENS  # noqa: E402

_cfg = json.load(io.open(
    'C:/Users/worms/OneDrive/문서/guide/.claude/settings.local.json',
    encoding='utf-8'))['env']
TOKEN = _cfg['NOTION_TOKEN']
PARENT_PAGE = _cfg['NOTION_PARENT_PAGE']
DB_TITLE = 'ART NARA 앱 기획 DB'


def api(method, path, body=None):
    req = urllib.request.Request('https://api.notion.com/v1' + path, method=method)
    req.add_header('Authorization', 'Bearer ' + TOKEN)
    req.add_header('Notion-Version', '2022-06-28')
    data = None
    if body is not None:
        data = json.dumps(body, ensure_ascii=False).encode('utf-8')
        req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req, data) as r:
            return r.status, json.loads(r.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        try:
            return e.code, json.loads(e.read().decode('utf-8'))
        except Exception:
            return e.code, {}


# ---------- 블록 헬퍼 ----------
def rt(text):
    """Notion 리치텍스트는 한 조각당 2000자 제한이 있다."""
    return [{'type': 'text', 'text': {'content': text[:2000]}}]


def heading(text):
    return {'object': 'block', 'type': 'heading_2',
            'heading_2': {'rich_text': rt(text)}}


def para(text):
    return {'object': 'block', 'type': 'paragraph',
            'paragraph': {'rich_text': rt(text)}}


def bullet(text):
    return {'object': 'block', 'type': 'bulleted_list_item',
            'bulleted_list_item': {'rich_text': rt(text)}}


def callout(text):
    return {'object': 'block', 'type': 'callout',
            'callout': {'rich_text': rt(text), 'icon': {'emoji': '📌'}}}


def figma_url(s):
    if not s['file'] or not s['node']:
        return ''
    return 'https://www.figma.com/design/%s/?node-id=%s' % (
        s['file'], s['node'].replace(':', '-'))


def body_blocks(s):
    blocks = [callout(s['summary']), heading('사용자 시나리오'), para(s['scenario']),
              heading('화면 구성')]
    blocks += [bullet(x) for x in s['layout']]
    blocks += [heading('주요 기능')] + [bullet(x) for x in s['features']]
    blocks += [heading('완료 기준')] + [bullet(x) for x in s['done']]
    if s.get('notes'):
        blocks += [heading('개발 참고')] + [bullet(x) for x in s['notes']]
    blocks += [heading('연결'), para(s['deps']),
               para('구현 파일: frontend/lib/screens/' + s['code'])]
    return blocks


def properties(s):
    url = figma_url(s)
    props = {
        '이름': {'title': rt('[%s] %s' % (s['id'], s['name']))},
        '화면 ID': {'rich_text': rt(s['id'])},
        '화면': {'select': {'name': s['group']}},
        '구분': {'select': {'name': '화면'}},
        '노드 ID': {'rich_text': rt(s['node']) if s['node'] else []},
        '요약': {'rich_text': rt(s['summary'])},
        '사용자 시나리오': {'rich_text': rt(s['scenario'])},
        '완료 기준': {'rich_text': rt(' / '.join(s['done']))},
        '의존·참고': {'rich_text': rt(s['deps'])},
        '구현 파일': {'rich_text': rt(s['code'])},
        '버전': {'select': {'name': 'v1.0 MVP'}},
        '상태': {'select': {'name': '개발 완료'}},
        '이미 개발됨': {'checkbox': True},
        '담당자': {'rich_text': []},
        '우선순위': {'select': None},
    }
    if url:
        props['Figma URL'] = {'url': url}
    return props


DB_PROPS = {
    '이름': {'title': {}},
    '화면 ID': {'rich_text': {}},
    'Figma URL': {'url': {}},
    '구분': {'select': {'options': [{'name': '화면', 'color': 'blue'},
                                  {'name': '공통', 'color': 'gray'}]}},
    '노드 ID': {'rich_text': {}},
    '담당자': {'rich_text': {}},
    '목표일': {'date': {}},
    '버전': {'select': {'options': [{'name': 'v1.0 MVP', 'color': 'purple'},
                                  {'name': 'v1.1', 'color': 'default'}]}},
    '사용자 시나리오': {'rich_text': {}},
    '상태': {'select': {'options': [
        {'name': '개발 완료', 'color': 'green'},
        {'name': '개발 중', 'color': 'blue'},
        {'name': '기획 중', 'color': 'gray'},
        {'name': '보류', 'color': 'default'},
    ]}},
    '완료 기준': {'rich_text': {}},
    '요약': {'rich_text': {}},
    '우선순위': {'select': {'options': [{'name': 'P0', 'color': 'red'},
                                    {'name': 'P1', 'color': 'orange'},
                                    {'name': 'P2', 'color': 'yellow'}]}},
    '의존·참고': {'rich_text': {}},
    '이미 개발됨': {'checkbox': {}},
    '구현 파일': {'rich_text': {}},
    '화면': {'select': {'options': [
        {'name': '00_진입', 'color': 'gray'},
        {'name': '10_홈', 'color': 'blue'},
        {'name': '20_거래', 'color': 'green'},
        {'name': '30_판매', 'color': 'orange'},
        {'name': '40_의뢰', 'color': 'purple'},
        {'name': '50_지도', 'color': 'brown'},
        {'name': '60_소유권', 'color': 'yellow'},
        {'name': '70_소통', 'color': 'pink'},
        {'name': '80_마이', 'color': 'red'},
    ]}},
}


def find_database():
    st, res = api('POST', '/search',
                  {'query': DB_TITLE, 'filter': {'value': 'database', 'property': 'object'}})
    for r in res.get('results', []):
        title = ''.join(t.get('plain_text', '') for t in r.get('title', []))
        if title == DB_TITLE:
            return r['id']
    return None


def main():
    db_id = find_database()
    if db_id:
        print('기존 DB 사용:', db_id)
    else:
        st, res = api('POST', '/databases', {
            'parent': {'type': 'page_id', 'page_id': PARENT_PAGE},
            'title': [{'type': 'text', 'text': {'content': DB_TITLE}}],
            'properties': DB_PROPS,
        })
        if st != 200:
            print('DB 생성 실패', st, json.dumps(res, ensure_ascii=False)[:400])
            return
        db_id = res['id']
        print('DB 생성:', db_id, res.get('url'))

    # 기존 행 조회 (화면 ID -> page_id)
    existing = {}
    cursor = None
    while True:
        body = {'page_size': 100}
        if cursor:
            body['start_cursor'] = cursor
        st, res = api('POST', '/databases/%s/query' % db_id, body)
        if st != 200:
            break
        for row in res.get('results', []):
            sid = ''.join(t.get('plain_text', '')
                          for t in row['properties'].get('화면 ID', {}).get('rich_text', []))
            if sid:
                existing[sid] = row['id']
        if not res.get('has_more'):
            break
        cursor = res.get('next_cursor')

    created = updated = failed = 0
    for s in SCREENS:
        props = properties(s)
        if s['id'] in existing:
            st, res = api('PATCH', '/pages/' + existing[s['id']], {'properties': props})
            tag = '갱신'
            updated += 1
        else:
            st, res = api('POST', '/pages', {
                'parent': {'database_id': db_id},
                'properties': props,
                'children': body_blocks(s),
            })
            tag = '생성'
            created += 1
        if st != 200:
            failed += 1
            created -= 1 if tag == '생성' else 0
            updated -= 1 if tag == '갱신' else 0
            print('  실패 %s %s: %s' % (s['id'], st, json.dumps(res, ensure_ascii=False)[:200]))
        else:
            print('  %s %s %s' % (tag, s['id'], s['name']))

    print('=' * 50)
    print('생성 %d · 갱신 %d · 실패 %d' % (created, updated, failed))
    st, res = api('GET', '/databases/' + db_id)
    print('DB URL:', res.get('url'))


if __name__ == '__main__':
    main()
