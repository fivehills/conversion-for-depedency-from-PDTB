# conversion-for-depedency-from-PDTB

1) Double click “batch.bat ” to run, and the result file is “result_fined.txt”.

2) “batch.bat” file includes two commands: (a) perl step1.pl <pdtb_file> # can replace pdtb_file with the actual file name, e.g.: perl step1.pl wsj_0168; (b) perl step2.pl.

3) Some other debugging files for reference, can be ignored.

4) Currently debugging only for “wsj_0168” file, and it requires the input file format column 14 and column 20 data flush. In this version, robustness checking are not guaranteed.

5) The converting folder includes the following files: pdtb format files (wsj_0618), batch.bat, step1.pl, step2.pl. After running above, other files are dynamically generated after running.

6) Note the current programming scripts are written by Perl. We will upload the Python version soon. 
