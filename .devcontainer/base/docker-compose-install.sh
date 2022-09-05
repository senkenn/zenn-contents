# 実行ファイルDL
curl -L "https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-$(uname -s)-$(uname -m)" \
     -o /usr/local/bin/docker-compose
# 実行権限付与とシンボリックリンク作成
chmod +x /usr/local/bin/docker-compose && \
ln -fs /usr/local/bin/docker-compose /usr/bin/docker-compose
