/// Gera a página pública da política de privacidade a partir do Markdown.
///
/// **A fonte de verdade do texto está no repositório do app**, em
/// `docs/privacidade.md`: é lá que a política é escrita e revisada junto com o
/// que o app faz. Este repositório guarda só a **saída** — `public/index.html`,
/// que é o que vai ao ar.
///
/// Existe para o texto legal não viver em duas versões. Um HTML escrito à mão ao
/// lado de um Markdown com o mesmo conteúdo divergem na primeira correção feita
/// só de um lado, e a política é justamente o documento em que divergir é caro.
///
/// O preço da escolha: **regenerar exige o repositório do app ao lado deste**
/// (ver [defaultSource]). Um clone isolado não refaz a página — mas também não
/// precisa, porque o HTML vai commitado e o deploy não roda build.
///
/// Uso:
///
/// ```
/// dart run tool/build.dart            # regenera public/index.html
/// dart run tool/build.dart --check    # nada é escrito; sai 1 se a página atrasou
/// dart run tool/build.dart --source=outro/caminho/privacidade.md
/// ```
library;

import 'dart:io';

import 'package:markdown/markdown.dart' as md;

/// O Markdown da política, no repositório do app. Caminho relativo porque os
/// dois repositórios são irmãos na mesma pasta de trabalho; `--source` cobre
/// quem os tiver em outro lugar.
const defaultSource = '../marco/docs/privacidade.md';

/// O que o Cloudflare publica. Tudo fora daqui — `pubspec.yaml`, `tool/`, este
/// comentário — fica fora do ar.
const outputDir = 'public';

/// O placeholder do e-mail de contato. A política é pública e o campo fica
/// visível, então publicar com ele dentro é publicar um rascunho.
const contactPlaceholder = 'PREENCHER';

void main(List<String> args) {
  final check = args.contains('--check');
  final sourceArg = args.firstWhere(
    (arg) => arg.startsWith('--source='),
    orElse: () => '',
  );
  final sourcePath = sourceArg.isEmpty
      ? defaultSource
      : sourceArg.substring('--source='.length);

  final source = File(sourcePath);
  if (!source.existsSync()) {
    stderr.writeln(
      'Não achei o Markdown da política em "$sourcePath".\n'
      'A fonte fica no repositório do app; clone-o ao lado deste ou passe '
      '--source=<caminho>.',
    );
    exit(2);
  }
  final markdown = source.readAsStringSync();
  final page = renderPage(markdown);
  final output = File('$outputDir/index.html');

  if (check) {
    warnAboutPlaceholder(markdown);
    final current = output.existsSync() ? output.readAsStringSync() : null;
    if (current == page) {
      stdout.writeln('${output.path} está em dia com "$sourcePath".');
      return;
    }
    stderr.writeln(
      '${output.path} atrasou em relação a "$sourcePath".\n'
      'Rode `dart run tool/build.dart`.',
    );
    exit(1);
  }

  output.writeAsStringSync(page);
  stdout.writeln('${output.path} ← $sourcePath');
  warnAboutPlaceholder(markdown);
}

void warnAboutPlaceholder(String markdown) {
  if (!markdown.contains(contactPlaceholder)) return;
  stderr.writeln(
    'ATENÇÃO: o e-mail de contato ainda é um placeholder '
    '($contactPlaceholder). Preencha no Markdown do app antes de publicar.',
  );
}

/// O Markdown vira o corpo da página; o resto é a moldura, que não muda.
///
/// `gitHubWeb` é o conjunto de extensões que traz **tabela** — a política tem uma
/// (as permissões e o porquê de cada uma), e sem ele ela sairia como parágrafo
/// com barras verticais no meio. É ele também que transforma e-mail solto em
/// `mailto:`, e é por isso que o Markdown escreve o endereço puro: link explícito
/// sairia como `<a>` dentro de `<a>`.
String renderPage(String markdown) {
  final body = md.markdownToHtml(
    markdown,
    extensionSet: md.ExtensionSet.gitHubWeb,
  );

  return '''
<!doctype html>
<!-- Arquivo gerado por tool/build.dart. Edite docs/privacidade.md no repositório do app. -->
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Política de Privacidade — marco</title>
<meta name="description" content="O marco não coleta dados: tudo o que você cria fica no seu aparelho.">
<meta name="color-scheme" content="dark light">
<link rel="icon" href="/icone.png" type="image/png">
<link rel="stylesheet" href="/estilo.css">
</head>
<body>
<main class="janela">
$body</main>
<footer>marco — metas e rotinas pessoais, com os dados no seu aparelho.</footer>
</body>
</html>
''';
}
