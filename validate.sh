#!/bin/bash
## Perform several validation tests on the files in a downloaded data snapshot

# Check for xml well formedness errors
for f in data/*/*; do
    # Check file is not empty
    if [[ -s $f ]]; then
        xmllint $f > /dev/null
    fi
done 2> xmlerrors
# Prevent empty gist that won't be uploaded
echo "." >> xmlerrors
$GIST && gist xmlerrors -u 6726333

# List all root elements in our xml files
for f in data/*/*; do
    if [[ -s $f ]]; then
        echo "`xmllint --xpath "name(/*)" "$f"` $f";
    fi        
done > topelements
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


# Validate all the files against the relevant schema
for f in data/*/*; do
    if [[ -s $f ]]; then
        echo $f;
    fi
done > list   
for f in data/*/*; do 
    if [[ -s $f ]]; then
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
    fi
done > list-validate
comm -23 list list-validate > list-fail-validate

wc -l list* | sed '/total/ d' > 0_list-summary
$GIST && gist -u 6931534 0_list-summary list-fail-validate


# Group the validation failures by publisher
cat list | sed 's/^data\///' | sed 's/\/.*$//' | sort | uniq > publishers
cat list-fail-validate | sed 's/^data\///' | sed 's/\/.*$//' | sort | uniq > publishers-somefail
cat list-validate | sed 's/^data\///' | sed 's/\/.*$//' | sort | uniq > publishers-someokay

comm -12 publishers-somefail publishers-someokay > publishers-onlysomefail
comm -23 publishers-somefail publishers-someokay > publishers-allfail
comm -13 publishers-somefail publishers-someokay > publishers-allokay

wc -l publishers* > 0_publishers-summary

$GIST && gist -u 6991379 0_publishers-summary publishers-allfail publishers-onlysomefail



# List publishers with/without an organisation file
cat topelements | grep iati-organisations | sed -e 's|iati-organisations data/||' -e 's|/.*$||' | sort | uniq > haveorg
comm -23 publishers haveorg > nohaveorg
wc -l *haveorg > 0_haveorg-summary
$GIST && gist -u 6992244 0_haveorg-summary nohaveorg 

