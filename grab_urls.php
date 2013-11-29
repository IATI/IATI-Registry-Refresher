<?php
/*
 *      grab_urls.php
 *      
 *      Copyright 2012 caprenter <caprenter@gmail.com>
 *      
 *      This file is part of IATI Registry Refresher.
 *      
 *      IATI Registry Refresher is free software: you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License as published by
 *      the Free Software Foundation, either version 3 of the License, or
 *      (at your option) any later version.
 *      
 *      IATI Registry Refresher is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *      GNU General Public License for more details.
 *      
 *      You should have received a copy of the GNU General Public License
 *      along with IATI Registry Refresher.  If not, see <http://www.gnu.org/licenses/>.
 * 
 *      IATI Registry Refresher relies on other free software products. See the README.txt file 
 *      for more details.
 */


// Display errors for demo
@ini_set('error_reporting', E_ALL);
@ini_set('display_errors', 'stdout');
  
// Function to perform an API request against the IATI Registry CKAN v3 API
function api_request($path, $data=null) {
    $api_root = "http://iatiregistry.org/api/3/";

    if ($data === null) $data_string = '{}';
    else $data_string = json_encode($data);

    $ch = curl_init($api_root.$path);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json',
        'Content-Length: '.strlen($data_string))
    );

    $result = curl_exec($ch);
    curl_close($ch);

    return json_decode($result)->result;
}
  
//Empty variables    
$urls = array();

//Pull all the group identifiers from the registry
//We store them in an array , $groups, for later use
$groups = api_request('action/group_list');
//Switch to this when iatiregistry.org transitions to CKAN 2:
//$groups = api_request('action/organization_list');

//Overide the group array, e.g. for testing. Uncomment and edit the line(s) below
//$groups = array("hewlett-foundation","aa");
//$groups = array("dfid");


//Loop through each group and save the URL end-points of the data files
//You may need to set up an empty directory called "urls"
echo "Fetching:" . PHP_EOL;
foreach ($groups as $group) {
    $file = "urls/" . $group;
    echo $group."\n";
    try {
        $urls_string = '';
        $packages = api_request('action/group_package_show', array('id'=>$group));
        foreach ($packages as $package) {
            try {
                $urls_string .= $package->name . ' ' . (string)$package->resources[0]->url . PHP_EOL;
            } catch (Exception $e) {
                // Catch exceptions here to prevent one url from breaking an entire publisher
                print 'Caught exception in '.$file.': ' . $e->getMessage();
            }
        }
        file_put_contents($file, $urls_string, LOCK_EX);
    } catch (Exception $e) {
        print 'Caught exception in '.$file.': ' . $e->getMessage();
    }
}

?>


