### dependence の実装
* http://deps.cpantesters.org/depended-on-by.pl?dist=Module-version
    * 比較的新しいバーションしかない？
    * dist 名と .packlist が置いてある場所が違うのが取れない

            +----------+-----------+
            |.packlist | dist      |
            +----------+-----------+
            |CGI       | CGI.pm    |
            |Cwd       | PathTools |
            +----------+-----------+
            ?dist=CGI.pm-3.49 とかしないとだめ
            

### .packlist がないやつってあるのかな・・・？とか
