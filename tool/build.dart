/// Gera a página pública da política de privacidade a partir do Markdown.
///
/// **A fonte de verdade do texto é o repositório do app**, em
/// `docs/privacidade.md`: é lá que a política é escrita e revisada junto com o
/// que o app faz. Este repositório guarda uma cópia (`privacidade.md`) e o HTML
/// publicado (`public/index.html`) — os dois são **saída**, não fonte.
///
/// Existe para o texto legal não viver em duas versões. Um HTML escrito à mão ao
/// lado de um Markdown com o mesmo conteúdo divergem na primeira correção que
/// alguém faz só de um lado, e a política é justamente o documento em que
/// divergir é caro.
///
/// Uso:
///
/// ```
/// dart run tool/build.dart                 # regenera a partir da cópia local
/// dart run tool/build.dart --source=../marco/docs/privacidade.md
/// dart run tool/build.dart --check         # nada é escrito; sai 1 se atrasou
/// ```
library;

import 'dart:io';

import 'package:markdown/markdown.dart' as md;

/// A cópia local do texto, que o HTML publicado espelha.
const localSource = 'privacidade.md';

/// O que o Cloudflare Pages publica. Tudo fora daqui — `pubspec.yaml`, `tool/`,
/// este comentário — fica fora do ar.
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
      ? localSource
      : sourceArg.substring('--source='.length);

  final source = File(sourcePath);
  if (!source.existsSync()) {
    stderr.writeln('Não achei o Markdown da política em "$sourcePath".');
    exit(2);
  }
  final markdown = source.readAsStringSync();
  final page = renderPage(markdown);

  final localCopy = File(localSource);
  final output = File('$outputDir/index.html');

  if (check) {
    final stale = [
      if (readOrNull(localCopy) != markdown) localSource,
      if (readOrNull(output) != page) output.path,
    ];
    warnAboutPlaceholder(markdown);
    if (stale.isEmpty) {
      stdout.writeln('Em dia com "$sourcePath".');
      return;
    }
    stderr.writeln(
      'Atrasado em relação a "$sourcePath": ${stale.join(', ')}.\n'
      'Rode `dart run tool/build.dart --source=$sourcePath`.',
    );
    exit(1);
  }

  // A cópia local só é reescrita quando a fonte é outra: rodar sem `--source`
  // regenera o HTML sem mexer no texto.
  if (source.absolute.path != localCopy.absolute.path) {
    localCopy.writeAsStringSync(markdown);
    stdout.writeln('$localSource ← $sourcePath');
  }
  output.writeAsStringSync(page);
  stdout.writeln('${output.path} gerado.');
  warnAboutPlaceholder(markdown);
}

String? readOrNull(File file) =>
    file.existsSync() ? file.readAsStringSync() : null;

void warnAboutPlaceholder(String markdown) {
  if (!markdown.contains(contactPlaceholder)) return;
  stderr.writeln(
    'ATENÇÃO: o e-mail de contato ainda é um placeholder '
    '($contactPlaceholder). Preencha no Markdown do app antes de publicar.',
  );
}

/// O Markdown vira o corpo da página; o resto é a moldura, que não muda.
///
/// `gitHubWeb` é o conjunto de extensões que traz **tabela** — a política tem
/// duas (permissões e o que o app não faz), e sem ele elas sairiam como
/// parágrafos com barras verticais no meio.
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
