# MySQL 8
if [[ -d /opt/homebrew/opt/mysql@8.0 ]]; then
  export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"
  export LDFLAGS="-L/opt/homebrew/opt/mysql@8.0/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/mysql@8.0/include"
fi
