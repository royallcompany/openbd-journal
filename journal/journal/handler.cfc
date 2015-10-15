<cfcomponent><cfscript>
/**
	* OpenBD Journaling Tool
  * Copyright (C) 2015
  *
  * This program is free software: you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation, either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU General Public License
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
	*/

	this.JOURNAL_PATH = GetJournaldirectory();
	this.DATA_SOURCE = "journaling";
	this.TABLE_NAME = "journalMetadata";


	public component function init() {
		// Create the journal metadata table if it doesn't exist
		queryRun( this.DATA_SOURCE, "CREATE TABLE IF NOT EXISTS #this.TABLE_NAME# ( id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR, shortName INT, startingUri VARCHAR, created DATETIME, output INT, size INT, time INT );" );

		// Get the journal files
		var fileQu = DirectoryList(this.JOURNAL_PATH, true, "query", "*.txt", "datelastmodified desc");
		var short;
		var jInfo;

		// Add journals to metadata database if it's not already there
		for ( i = 1; i <= fileQu.recordCount; i++ ) {
			short = Right(reReplace(fileQu.name[i], "[^0-9]", "", "ALL"), 8);

			if ( queryRun(this.DATA_SOURCE, "SELECT shortName FROM #this.TABLE_NAME# WHERE shortName LIKE #short#").recordCount == 0 ) {
				jInfo = journalRead(this.JOURNAL_PATH & fileSeparator() & fileQu.name[i]);

				queryRun( this.DATA_SOURCE, "INSERT INTO #this.TABLE_NAME# (name, shortName, startingUri, created, output, size, time) VALUES ('#fileQu.name[i]#', #short#, '#listFirst(jInfo._uri, "?")#', #fileQu.datelastmodified[i]#, #jInfo._bytes#, #fileQu.size[i]#, #jInfo._timems#)");
			}
		}
	}



	remote struct function getJournalData(page, perPage, offset, sorts) returnformat="JSON" {
		var qry = "SELECT * FROM journalMetadata";
		console(arguments); // RESUME how to handle sorting: sorts[TIME]

		var jData = queryRun(this.DATA_SOURCE, qry);

		// Dynatree expected format
		var journals = {
			records: [],
			queryRecordCount: jData.recordCount,
			totalRecordCount: perPage
		};

		for ( var i = 1; i <= jData.recordCount; i++ ) {
			arrayAppend(journals.records, queryRowStruct(jData, i));
		}

		return journals;
	}
</cfscript></cfcomponent>