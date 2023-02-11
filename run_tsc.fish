function run_tsc 
    set pgmname (basename $argv[1] .ts)
    tsc $pgmname.ts; and node $pgmname.js $argv[2..-1]
end