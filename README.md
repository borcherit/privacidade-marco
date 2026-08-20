# privacidade-marco

A **política de privacidade pública** do app [marco](../marco), servida como
página estática no Cloudflare Pages. A URL desta página é a que vai nos dois
consoles de loja (Google Play → *Data safety*; App Store → *App Privacy*), que
exigem um endereço público — arquivo em repositório não serve.

## O que é fonte e o que é saída

| Arquivo | O que é |
|---|---|
| `../marco/docs/privacidade.md` | **A fonte.** O texto é escrito e revisado no repositório do app, junto com o que o app faz. |
| `privacidade.md` | Cópia da fonte, gravada pelo gerador. Não edite à mão. |
| `public/index.html` | A página publicada, gerada do Markdown. Não edite à mão. |
| `public/estilo.css` | Escrito à mão. Paleta do app (Obsidiana no escuro, Cotton no claro). |
| `public/_headers` | Cabeçalhos que o Pages aplica (CSP, `nosniff`, `DENY` de iframe). |
| `public/icone.png` | O ícone do app, variante Obsidiana — o mesmo `assets/icon/ios_1024_obsidian.png`. |

Duas versões do mesmo texto legal divergem na primeira correção feita só de um
lado, e é por isso que o HTML é gerado em vez de escrito: a política tem um único
lugar onde se edita.

## Regenerar depois de mudar a política

```sh
dart pub get                                                  # uma vez
dart run tool/build.dart --source=../marco/docs/privacidade.md
```

Sem `--source`, o gerador usa a cópia local e só refaz o HTML — útil quando o que
mudou foi o CSS ou a moldura da página.

```sh
dart run tool/build.dart --check    # sai 1 se a página atrasou em relação à fonte
```

## Antes do primeiro deploy

- [ ] **Preencher o e-mail de contato** no fim de `../marco/docs/privacidade.md`
      (hoje está `<PREENCHER: e-mail de contato público>`) e regenerar. O endereço
      fica **público**: convém um criado para isso, não um pessoal nem o
      corporativo. O gerador avisa enquanto o placeholder estiver lá.
- [ ] Conferir a data de **Última atualização** no topo do texto.

## Cloudflare Pages

Projeto novo → **Connect to Git** → este repositório, e então:

| Campo | Valor |
|---|---|
| Framework preset | `None` |
| Build command | *(vazio)* |
| Build output directory | `public` |

Não há build: o HTML já está pronto no repositório, e o Pages só serve a pasta.
É também por isso que a saída fica em `public/` — `pubspec.yaml`, `tool/` e este
README ficam de fora do que vai ao ar.

Cada `git push` na `main` publica. A URL sai como
`https://privacidade-marco.pages.dev/` (ou o domínio próprio, se você ligar um em
*Custom domains* — o endereço nos consoles das lojas deve ser o **definitivo**,
porque muda com a ficha do app já publicada).

Depois de publicar, confira que a página abre em aba anônima e que
`https://<domínio>/estilo.css` responde — CSP e caminho absoluto (`/estilo.css`)
dependem de a saída estar na raiz do site, não numa subpasta.
