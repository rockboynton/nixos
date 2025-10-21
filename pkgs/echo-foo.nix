{ writeShellScriptBin }:

writeShellScriptBin "echo-foo" ''
  echo foo
''
