#!/usr/bin/env bash

script=$(cat << EOF
#!/usr/bin/env bash
#
# Autor: Marcelo Magalhães
#
# Rejeita um commit enquanto houver arquivos fora da norma
# Dê permissão de execução e coloque em .git/hooks

RESET='\033[m'
YELLOW='\033[1;33m'

IGNORE=".normignore"

check_ignored() {
  if ! norminette "\$1" | grep "^Error" | grep -qivf "\$IGNORE"; then
    return 1
  fi
}

normal_check() {
  norminette "\$1" | grep -q "^Error"
}

stop_message() {
  echo -e "\${YELLOW}COMMIT REJECTED\${RESET}: norm error!"
}

check_norm_error() {
  if [[ -f "\$IGNORE" ]]; then
    check_ignored "\$1"
  else
    normal_check "\$1"
  fi
}

main() {
  for file in \$(git diff --cached --name-only); do
    filename=\$(basename "\$file")
    case "\$filename" in
      *.h | *.c)
        if check_norm_error "\$file"; then
          stop_message
          exit 1
        fi
      ;;
    esac
  done
  exit 0
}

main
EOF
)

if [[ -d $PWD/.git/hooks ]]; then
  echo "$script" > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  echo 'Done!'
else
  echo "Not a git repository"
  exit 1
fi
