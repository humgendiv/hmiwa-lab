# hmiwa-lab
解析スクリプト等管理用（new）

(2023/11/05)
* d_20231023:現在使用中
* hmiwa-labserver:ラボサーバ用レポジトリ統合版（更新終了）
* coming soon...

### レポジトリ統合手順

    cd /Users/hmiwa/Documents/GitHub

    cd d_20231023 #d_20231023はアーカイブ済み
    git pull git@github.com:hmiwa30/d_20231023.git
    git fetch

    cd /Users/hmiwa/Documents/GitHub
    git clone git@github.com:humgendiv/hmiwa-lab.git

    cd hmiwa-lab
    mkdir d_20231023
    touch d_20231023/.gitkeep
    git add -A d_20231023
    git commit -m "create d_20231023 dir"

    git remote add d_20231023 /Users/hmiwa/Documents/GitHub/d_20231023
    git fetch d_20231023
    git merge --allow-unrelated-histories -X subtree=d_20231023 d_20231023/main
    git push git@github.com:humgendiv/hmiwa-lab.git

    cd /Users/hmiwa/Documents/GitHub
    rm -r hmiwa-lab #トラブルを起こしたので一旦消去（ここまでの分は既にすべてupdate済み）
    git clone git@github.com:humgendiv/hmiwa-lab.git

    cd /Users/hmiwa/Documents/GitHub
    cd hmiwa-labserver
    git pull git@github.com:humgendiv/hmiwa-labserver.git

    cd hmiwa-lab
    mkdir hmiwa-labserver
    touch hmiwa-labserver/.gitkeep
    git add -A hmiwa-labserver
    git commit -m "create hmiwa-labserver dir"

    git remote add hmiwa-labserver /Users/hmiwa/Documents/GitHub/hmiwa-labserver
    git fetch hmiwa-labserver
    git merge --allow-unrelated-histories -X subtree=hmiwa-labserver hmiwa-labserver/main
    git push git@github.com:humgendiv/hmiwa-lab.git
