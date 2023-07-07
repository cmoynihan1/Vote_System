# Voting System

### Deliverables

- A rails application and associated database to hold the data
- A basic web front-end to view the results which should;
    - Present a list of campaigns for which we have results.
    - When the user clicks on a campaign, present a list of the
      candidates, their scores, and the number of messages which were sent in
      but not counted
- A command-line script that will import log file data into the application.
  Any lines that are not well-formed should be discarded. The sample data
  has been compressed to be emailed to you, but your script should assume
  the data is uncompressed plain text.
- A description of your approach to this problem, including any
  significant design decisions and your reasoning in making your
  choices. (This is the most important deliverable)

> Ruby Version: 2.7.7 - 
> *Latest Installed on my machine at the time of Dev* 


How to run rake task

    rake count_votes[app_relative_path_to_file]

Example 

    rake count_votes\["lib/assets/votes.txt"]


## Design Choices

### Data structure

The first design aspect I considered was the database structure. I initially thought about splitting the data into three tables Campaigns/Candidates/Votes. With the relationship between Campaigns and Candidates being a has_many_through the Votes table.

This would have allowed a candidate to belong to many campaigns without having duplicate data.

In the end I thought this was an over-complication. There is no requirement to store the individual votes. So instead I only have a two table structure Campaigns and Candidates. These objects hold information about their respective vote counts. The candidates name + campaign id could form a primary key, as this will be unique, however I am just using the rails ID. 

If requirements develop, and it becomes important to keep more information about individual results then the initial design mentioned could be implemented. 

>Campaigns
> - has many Candidates
 > - campaign_id: from first text unique
 > - total_votes: int
> - valid_votes: int
> - errors: int
> - invalid votes: int

> Candidates
> - belongs to campaigns
> - id: rails id
> - name: text not unique
> - votes: int
> - campaign_id: related to a campaign

  On the campaign data structure, I split the error and invalid votes out as the spec didn't say to store them together.

  The candidate names not unique as candidates could have the same name on different campaigns.

  The campaign_id field on a campaign is unique and is used to determine which campaign vote applies.
  
  I've set default values (0) for vote fields. This allows incoming results to be added without needing to check for nil values.


### Models

#### Candidate model

Nothing to add here, has a belongs to on the Campaign.

#### Campaign model
Has a method for ingesting count data from a hash structure.

Parent relationship with candidate to allow for query method (Campaign(instance).candidates) when updating scores.

The idea of the implementation is to allow for campaign scores to be ingested from multiple files. Score are not overwritten just added to. 

In the future we might need to add an identifier to files ingested so that if the same file is used, votes will not be counted twice.

Invalid and errors votes are added to the campaign as there are no candidates involved.

Added methods to the model for getting total votes and total bad votes. This is a small calculation so will not add too much overhead at runtime.


### Rake Task

#### Key Points

- Counting hash object adds a new method to hash object that will allow me to count candidate votes, first count sets up the hash with a value of 1 from then on it will increment the count.


- Lines are validated through strict steps which will raise an error if line is malformed.


- Results of count stored in memory as a hash to be added to the database. This reduces calls to the database as each vote does not invoke a database call. This could be an issue if large data files are ingested as results are stored in memory first. Might need a different approach if large ingestion files becomes a requirement.


- Identifier values are frozen to imporve memory efficiency.
