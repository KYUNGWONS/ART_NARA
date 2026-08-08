# ART NARA API 문서

## Swagger UI

서버를 띄우고 브라우저에서 열면 API 를 직접 호출해 볼 수 있다.

```bash
cd backend && ./run-dev.sh --bg
```

- Swagger UI: http://localhost:8080/swagger-ui/index.html
- OpenAPI 스펙: http://localhost:8080/v3/api-docs

## openapi.json

이 폴더의 `openapi.json` 은 위 스펙을 내보낸 것이다(오퍼레이션 60개). Postman·Insomnia 로 가져오거나
클라이언트 코드 생성에 쓸 수 있다. 갱신하려면:

```bash
curl -s http://localhost:8080/v3/api-docs -o docs/api/openapi.json
```

## 자물쇠 표시 규칙

- 자물쇠가 **없는** API 는 토큰 없이 호출할 수 있다(공개 14개).
- 나머지는 `Authorize` 에 로그인 응답의 `accessToken` 을 넣어야 한다.
- 관리자 API(`/api/admin/**`)는 `/api/admin/login` 으로 받은 **별도 토큰**을 쓴다 —
  앱 토큰으로 부르면 403 이다.

공개 여부는 `SecurityConstant` 와 컨트롤러의 `@SecurityRequirements` 를 함께 맞춰 둔 것이라,
보안 규칙을 바꾸면 애노테이션도 같이 고쳐야 문서가 어긋나지 않는다.
