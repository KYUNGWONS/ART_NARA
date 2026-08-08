# -*- coding: utf-8 -*-
"""사이드바 최상위에 'ART NARA' 페이지를 만들고, 그 안에 두 DB 를 둔다.

Getting Started(노션 기본 안내 페이지) 안에 있던 DB 를 옮기는 대신,
새 부모 페이지를 만들고 이후 빌드 스크립트가 그 아래에 DB 를 만들도록 설정을 갱신한다.
기존 DB 는 아카이브한다(휴지통에서 복구 가능).
"""
import io, json
from notion_api import api, rt

SETTINGS = 'C:/Users/worms/OneDrive/문서/guide/.claude/settings.local.json'
ROOT_TITLE = 'ART NARA'
DB_TITLES = ['ART NARA 앱 기획 DB', 'ART NARA 기술 문서']


def find_root():
    st, res = api('POST', '/search',
                  {'query': ROOT_TITLE, 'filter': {'value': 'page', 'property': 'object'}})
    for r in res.get('results', []):
        if r.get('parent', {}).get('type') != 'workspace':
            continue
        title = ''.join(t.get('plain_text', '')
                        for t in r['properties'].get('title', {}).get('title', []))
        if title == ROOT_TITLE and not r.get('archived'):
            return r['id']
    return None


def archive_old_dbs():
    for title in DB_TITLES:
        st, res = api('POST', '/search',
                      {'query': title, 'filter': {'value': 'database', 'property': 'object'}})
        for r in res.get('results', []):
            name = ''.join(t.get('plain_text', '') for t in r.get('title', []))
            if name == title and not r.get('archived'):
                api('PATCH', '/databases/' + r['id'], {'archived': True})
                print('  기존 DB 아카이브:', name)


def main():
    root = find_root()
    if root:
        print('기존 최상위 페이지 사용:', root)
    else:
        st, res = api('POST', '/pages', {
            'parent': {'type': 'workspace', 'workspace': True},
            'icon': {'type': 'emoji', 'emoji': '🎨'},
            'properties': {'title': {'title': rt(ROOT_TITLE)}},
            'children': [
                {'object': 'block', 'type': 'callout',
                 'callout': {'rich_text': rt(
                     '미대생 미술품 거래 플랫폼. 화면 기획과 기술 문서를 아래 두 DB 로 관리한다.'),
                     'icon': {'emoji': '🎨'}, 'color': 'gray_background'}},
            ],
        })
        if st != 200:
            print('최상위 페이지 생성 실패', st, str(res)[:300])
            return
        root = res['id']
        print('최상위 페이지 생성:', res.get('url'))

    archive_old_dbs()

    cfg = json.load(io.open(SETTINGS, encoding='utf-8'))
    cfg['env']['NOTION_PARENT_PAGE'] = root
    io.open(SETTINGS, 'w', encoding='utf-8').write(
        json.dumps(cfg, ensure_ascii=False, indent=2))
    print('부모 페이지 설정 갱신 완료 — 이제 build_notion_*.py 를 다시 실행하면 여기에 만들어진다')


if __name__ == '__main__':
    main()
