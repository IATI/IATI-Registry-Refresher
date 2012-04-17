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
  
  // Include Ckan_client
  require_once('Ckan_client.php');

  // Create CKAN object
  $ckan = new Ckan_client();
  
  //Empty variables    
  $urls = array();
  $urls_string="";


  //Pull all the group identifiers from the registry
  //We store them in an array , $data, for later use
  try
  {
    $data = $ckan->get_group_register();
    if ($data) {
    //print_r($data);
      for ($i = 0; $i < count($data); $i++) {
         echo $data[$i] . PHP_EOL;
      }
    }
  }
  catch (Exception $e)
  {
    print 'Caught exception: ' . $e->getMessage();
  }
  
//Loop through each group and save the URL end-points of the data files
//You may need to set up an empty directory called "urls"
$groups = $data;

//Overide the group array, e.g. for testing. Uncomment and edit the line(s) below
//$groups = array("hewlett-foundation","aa");
//$groups = array("dfid");

foreach ($groups as $group) {
  $file = "urls/" . $group;
  try
  {
    $data = $ckan->get_group_entity($group);
    if ($data):
    echo $data->title. PHP_EOL;
      //print '<blockquote><h3>' . $data->title . '</h3><p>' . 
        ///$data->description . '</p>';
      if (count($data->packages) > 0):
        foreach ($data->packages as $val):
          $package = $ckan->get_package_entity($val);
          $urls_string .= (string)$package->resources[0]->url . PHP_EOL;
        endforeach;
      endif;
      file_put_contents($file, $urls_string, LOCK_EX);
      $urls_string="";
    endif;
  }
  catch (Exception $e)
  {
    print 'Caught exception: ' . $e->getMessage();
  }

  //unset($ckan);
}
?>


