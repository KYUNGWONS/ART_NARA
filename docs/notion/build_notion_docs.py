# -*- coding: utf-8 -*-
"""tech_docs.py 를 읽어 Notion 에 'ART NARA 기술 문서' DB 를 만들고 페이지를 채운다.

여러 번 실행해도 안전하다: 문서 ID 로 기존 페이지를 찾아 있으면 본문을 갈아끼운다.
"""
import io, json, os, sys, urllib.request, urllib.error

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tech_docs import DOCS  # noqa: E402

_cfg = json.load(io.open(
    'C:/Users/worms/OneDrive/문서/guide/.claude/settings.local.json',
    encoding='utf-8'))['env']
TOKEN = _cfg['NOTION_TOKEN']
PARENT_PAGE = _cfg['NOTION_PARENT_PAGE']
DB_TITLE = 'ART NARA 기술 문서'


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


def rt(text):
    return [{'type': 'text', 'text': {'content': str(text)[:2000]}}]


def to_blocks(body):
    """(종류, 값) 리스트를 Notion 블록으로."""
    blocks = []
    for kind, value in body:
        if kind == 'h':
            blocks.append({'object': 'block', 'type': 'heading_2',
                           'heading_2': {'rich_text': rt(value)}})
        elif kind == 's':
            blocks.append({'object': 'block', 'type': 'paragraph',
                           'paragraph': {'rich_text': rt(value)}})
        elif kind == 'b':
            for item in value:
                blocks.append({'object': 'block', 'type': 'bulleted_list_item',
                               'bulleted_list_item': {'rich_text': rt(item)}})
        elif kind == 'c':
            blocks.append({'object': 'block', 'type': 'callout',
                           'callout': {'rich_text': rt(value),
                                       'icon': {'emoji': '💡'},
                                       'color': 'gray_background'}})
        elif kind == 'code':
            lang, text = value
            blocks.append({'object': 'block', 'type': 'code',
                           'code': {'rich_text': rt(text), 'language': lang}})
        elif kind == 't':
            rows = value
            width = len(rows[0])
            blocks.append({
                'object': 'block', 'type': 'table',
                'table': {
                    'table_width': width,
                    'has_column_header': True,
                    'has_row_header': False,
                    'children': [
                        {'object': 'block', 'type': 'table_row',
                         'table_row': {'cells': [rt(c) for c in row]}}
                        for row in rows
                    ],
                },
            })
    return blocks


DB_PROPS = {
    '제목': {'title': {}},
    '문서 ID': {'rich_text': {}},
    '분류': {'select': {'options': [
        {'name': '0_아키텍처', 'color': 'red'},
        {'name': '1_개요', 'color': 'gray'},
        {'name': '2_도메인', 'color': 'blue'},
        {'name': '3_인증보안', 'color': 'orange'},
        {'name': '4_외부연동', 'color': 'purple'},
        {'name': '5_관리자', 'color': 'green'},
        {'name': '6_개발환경', 'color': 'brown'},
        {'name': '7_QA', 'color': 'yellow'},
    ]}},
    '요약': {'rich_text': {}},
    '상태': {'select': {'options': [
        {'name': '작성 완료', 'color': 'green'},
        {'name': '작성 중', 'color': 'blue'},
        {'name': '갱신 필요', 'color': 'orange'},
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


def clear_children(page_id):
    """본문을 갈아끼우기 위해 기존 블록을 지운다."""
    st, res = api('GET', '/blocks/%s/children?page_size=100' % page_id)
    for blk in res.get('results', []):
        api('DELETE', '/blocks/' + blk['id'])


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
        print('DB 생성:', db_id)

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
            did = ''.join(t.get('plain_text', '')
                          for t in row['properties'].get('문서 ID', {}).get('rich_text', []))
            if did:
                existing[did] = row['id']
        if not res.get('has_more'):
            break
        cursor = res.get('next_cursor')

    created = updated = failed = 0
    for d in DOCS:
        props = {
            '제목': {'title': rt('[%s] %s' % (d['id'], d['title']))},
            '문서 ID': {'rich_text': rt(d['id'])},
            '분류': {'select': {'name': d['group']}},
            '요약': {'rich_text': rt(d['summary'])},
            '상태': {'select': {'name': '작성 완료'}},
        }
        blocks = to_blocks(d['body'])
        if d['id'] in existing:
            page_id = existing[d['id']]
            api('PATCH', '/pages/' + page_id, {'properties': props})
            clear_children(page_id)
            st, res = api('PATCH', '/blocks/%s/children' % page_id, {'children': blocks})
            tag, ok = '갱신', st == 200
            updated += 1 if ok else 0
        else:
            st, res = api('POST', '/pages', {
                'parent': {'database_id': db_id},
                'properties': props,
                'children': blocks,
            })
            tag, ok = '생성', st == 200
            created += 1 if ok else 0
        if not ok:
            failed += 1
            print('  실패 %s %s: %s' % (d['id'], st, json.dumps(res, ensure_ascii=False)[:220]))
        else:
            print('  %s %s %s' % (tag, d['id'], d['title']))

    print('=' * 50)
    print('생성 %d · 갱신 %d · 실패 %d' % (created, updated, failed))
    st, res = api('GET', '/databases/' + db_id)
    print('DB URL:', res.get('url'))


if __name__ == '__main__':
    main()
