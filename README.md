# msttstgen

MastdonのAtomフィードを遡って時間とステータスIDの対応表を作ります

## 使い方

    ./msttstgen.pl <AtomフィードのURL> <出力ファイル>

と実行すると

フィードを遡りながら、各ステータスごとに以下の行を出力していきます。

    UNIXTime,StatusID,DateTime

時報bot等を対象に実行すると一定時間ごとのテーブルが作りやすいと思います。
