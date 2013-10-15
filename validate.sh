#!/bin/bash
## Perform several validation tests on the files in a downloaded data snapshot

# Check for xml well formedness errors
xmllint data/*/* > /dev/null 2> xmlerrors
# Prevent empty gist that won't be uploaded
echo "." >> xmlerrors
$GIST && gist xmlerrors -u 6726333

# List all root elements in our xml files
for f in data/*/*; do echo "`xmllint --xpath "name(/*)" "$f"` $f"; done > topelements
# Upload to github gist all root elements that have names we don't expect
cat topelements | grep -v iati-activities | grep -v iati-organisations > nonstandardroots
# Prevent empty gist that won't be uploaded
echo "." >> nonstandardroots
$GIST && gist -u 6728773 nonstandardroots 

# List the version attribute of the root element of all xml files
for f in data/*/*; do echo "`xmllint --xpath "string(/*/@version)" "$f"` $f"; done > versions
# Summarise these
awk -F '[ ]' '{print $1}' versions | sort | uniq -c > 0_versions-summary
$GIST && gist -u 6729360 0_versions-summary versions


# Validate all the files
for f in data/*/*; do echo $f; done > list   
for f in data/*/*; do 
    topel="`xmllint --xpath "name(/*)" "$f"`"
    version="`xmllint --xpath "string(/*/@version)" "$f"`"
    if [ "$version" == "1.01" ] || [ "$version" == "1" ] || [ "$version" == "1.0" ] || [ "$version" == "1.00" ]; then version="1.01";
    elif [ "$version" == "1.02" ]; then version="1.02";
    else version="1.03"; fi
    if [ "$topel" == "iati-activities" ]; then
        xmllint --schema ~/iati/downloads/$version/iati-activities-schema.xsd --noout "$f" 2> /dev/null
        if [ $? -eq 0 ]; then echo $f; fi
    elif [ "$topel" == "iati-organisations" ]; then
        xmllint --schema ~/iati/downloads/$version/iati-organisations-schema.xsd --noout "$f" 2> /dev/null
        if [ $? -eq 0 ]; then echo $f; fi
    fi
done > list-validate
comm -23 list list-validate > list-fail-validate

wc -l list* | sed '/total/ d' > 0_list-summary
$GIST && gist -u 6931534 0_list-summary list-fail-validate

