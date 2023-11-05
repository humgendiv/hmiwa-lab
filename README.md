# hmiwa-lab
解析スクリプト等管理用（new）

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

    cd /Users/hmiwa/Documents/GitHub
    rm -r hmiwa-lab #トラブルを起こしたので一旦消去（ここまでの分は既にすべてupdate済み）
    git clone git@github.com:humgendiv/hmiwa-lab.git

    cd hmiwa-lab