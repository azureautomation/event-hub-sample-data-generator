Event Hub - Sample data generator
=================================

            




 
 
Generates sample Events for an Azure Event Hub.




The sample data is specific to temperature sensor data and should be used inside an Azure Automation Runbook on a schedule.


For best results I'd suggest creating a Stream Analytics job with your Event Hub as an input, and i've always found using PowerBi particuarly useful as an Output.  If you're not a fan of PowerBi, then it's just as easy to output to a storage account
 as CSV.


The script is fully documented with an example and parameter annotations to make it super simple to implement.


The only prerequisite is having an Event Hub deployed in order to fill in the various parameter values.


 


        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
