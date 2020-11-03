##
## Desc: copy all scripts to one directory.
##

CURR_DIR="$(cd "$(dirname "${0}")" && pwd)"
TARGET_DIR="${CURR_DIR}"/all_in_one
BASH_DIR="$(cd "$(dirname "${0}")/bash" && pwd)"
SQL_DIR="$(cd "$(dirname "${0}")/sql" && pwd)"

if [[ ! -d "${TARGET_DIR}" ]]; then
  mkdir -p "${TARGET_DIR}"
fi

find "${BASH_DIR}" -name *.sh  -type f -exec cp {} "${TARGET_DIR}"/ \;
find "${SQL_DIR}"  -name *.sql -type f -exec cp {} "${TARGET_DIR}"/ \;

chmod 700 "${TARGET_DIR}"/*
dos2unix "${TARGET_DIR}"/*
