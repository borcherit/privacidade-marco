# privacidade-marco

A **política de privacidade pública** do app [marco](../marco), servida como
página estática na Cloudflare:

**https://privacidade-marco.borcherit.workers.dev**

É essa URL que vai nos dois consoles de loja (Google Play → *Data safety*;
App Store → *App Privacy*), que exigem um endereço público — arquivo em
repositório não serve.

## O que é fonte e o que é saída

O texto **não** é editado aqui. Ele vive no repositório do app, em
`../marco/docs/privacidade.md`, onde é escrito e revisado junto com o que o app
faz. Este repositório guarda a página e a moldura dela:

| Arquivo | O que é |
|---|---|
| `public/index.html` | **Gerado** do Markdown do app. Não edite à mão. |
| `public/estilo.css` | Escrito à mão. Paleta do app (Obsidiana no escuro, Cotton no claro). |
| `public/_headers` | Cabeçalhos aplicados ao servir (CSP, `nosniff`, `DENY` de iframe). |
| `public/icone.png` | O ícone do app, variante Obsidiana — cópia de `assets/icon/ios_1024_obsidian.png`. |
| `tool/build.dart` | O gerador. |

Duas versões do mesmo texto legal divergem na primeira correção feita só de um
lado, e é por isso que o HTML é gerado em vez de escrito: a política tem um único
lugar onde se edita. O preço é que **regenerar exige o repositório do app ao lado
deste** — um clone isolado não refaz a página, e também não precisa, porque o HTML
vai commitado e o deploy não roda build.

## Regenerar depois de mudar a política

```sh
dart pub get                        # uma vez
dart run tool/build.dart            # lê ../marco/docs/privacidade.md
dart run tool/build.dart --check    # sai 1 se a página atrasou em relação à fonte
```

Se os dois repositórios não estiverem lado a lado:
`dart run tool/build.dart --source=<caminho>/privacidade.md`.

## Antes do deploy

- [ ] Conferir a data de **Última atualização** no topo do texto — ela é a data do
      documento, e um revisor de loja compara.
- [ ] Conferir que o e-mail de contato no fim do texto é o endereço público criado
      para isso, e não um pessoal ou corporativo. O gerador não passa em silêncio
      enquanto ele for um placeholder (`PREENCHER`).
- [ ] `dart run tool/build.dart --check` limpo, e a página commitada.

## Deploy

Cloudflare servindo **assets estáticos** da pasta `public/`, sem build: o HTML já
está pronto no repositório. É também por isso que a saída fica em `public/` —
`pubspec.yaml`, `tool/` e este README ficam de fora do que vai ao ar.

Com a integração de Git ligada, cada push na `main` publica. Depois de publicar,
confira em aba anônima:

```sh
curl -sI https://privacidade-marco.borcherit.workers.dev | grep -i "content-security\|x-frame"
```

Se os cabeçalhos do `public/_headers` não aparecerem, a plataforma não está lendo
o arquivo — a página continua correta, mas sem as travas. A URL nos consoles das
lojas deve ser a **definitiva**: trocá-la depois é submissão nova.
