#!/opt/homebrew/bin/fish

for f in src/*.typ
  printf '\n// FILE: %s\n\n' $f
  cat $f
end | pbcopy
