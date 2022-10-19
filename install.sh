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

stop_message() {
  echo -e "\${YELLOW}COMMIT REJECTED\${RESET}: norm error!"
}

check_norm_error () {
  norminette "\$1" | grep -q 'Error!' && stop_message
}

main() {
  for file in \$(git diff --cached --name-only); do
    filename=\$(basename "\$file")
    case "\$filename" in
      *.h | *.c)
        check_norm_error "\$file" && exit 1
      ;;
    esac
  done
  exit 0
}

main
EOF
)

if [[ -d $PWD/.git/hooks ]]; then
  echo "$script" | tee > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  echo 'Done!'
else
  echo "Not a git repository"
  exit 1
fi
