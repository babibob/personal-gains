# Counting and sort directiries and file by size
du -s * | sort -nr | cut -f 2- | while read a ; do du -hs $a ; done

# Only directories
du -s *| sort -nr | cut -f 2- | while read a ; do du -hs $a ; done | awk 'NR <=10'

# Create archive'
# -x: instructs tar to extract files.
# -f: specifies filename / tarball name.
# -v: Verbose (show progress while extracting files).
# -z: filter archive through gzip, use to decompress .gz files.
# -t: List the contents of an archive
tar -zxvf <tar filename> <file you want to extract>


# Find all repeated files
find -not -empty -type f -printf "%s\n" | sort -rn | uniq -d \
| xargs -I{} -n1 find -type f -size {}c -print0 \
| xargs -0 md5sum | sort | uniq -w32 --all-repeated=separate

# Find and remove files *com.*
find . -type f -name *com.* -print -exec /bin/rm {} \;