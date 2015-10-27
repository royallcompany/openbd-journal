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

	this.JOURNAL_PATH = GetJournaldirectory() & fileSeparator();
	this.DATA_SOURCE = "journaling";
	this.TABLE_NAME = "journalMetadata";


	/**
	  * @method init
	  * @public
	  */
	public component function init() {
		// Create the journal metadata table if it doesn't exist
		queryRun( this.DATA_SOURCE, "DROP TABLE #this.TABLE_NAME#;CREATE TABLE IF NOT EXISTS #this.TABLE_NAME# ( id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR, shortName INT, startingUri VARCHAR, created DATETIME, output INT, size INT, time INT );" );

		// Get the journal files
		var fileQu = DirectoryList(this.JOURNAL_PATH, true, "query", "*.txt", "datelastmodified desc");
		var short;
		var jInfo;

		// Add journals to metadata database if it's not already there
		for ( i = 1; i <= fileQu.recordCount; i++ ) {
			short = Right(reReplace(fileQu.name[i], "[^0-9]", "", "ALL"), 8);

			if ( queryRun(this.DATA_SOURCE, "SELECT shortName FROM #this.TABLE_NAME# WHERE shortName LIKE #short#").recordCount == 0 ) {
				console('yeah we did the thing'); // TODO
				jInfo = journalRead(this.JOURNAL_PATH & fileQu.name[i]);

				queryRun( this.DATA_SOURCE, "INSERT INTO #this.TABLE_NAME# (name, shortName, startingUri, created, output, size, time) VALUES ('#fileQu.name[i]#', #short#, '#listFirst(jInfo._uri, "?")#', #fileQu.datelastmodified[i]#, #jInfo._bytes#, #fileQu.size[i]#, #jInfo._timems#)");
			}
		}

		// record the total for later
		this.recordCount = fileQu.recordCount;
	}



	/**
		* Used by Dynatable, this returns the journal data based on the request.
		*
	  * @method getJournalsData
	  * @remote
	  * @param {string} [page = 1]
	  * @param {numeric} [perPage = 10]
	  * @param {numeric} [offset = 0]
	  * @param {string} [sorts = ""]
	  * @returnformat {JSON}
	  * @return {struct}
	  */
	remote struct function getJournalsData(string page = 1, numeric perPage = 10, numeric offset = 0, string sorts = "") returnformat="JSON" {
		this.init();

		var qry = "SELECT * FROM journalMetadata";

		// Build up the query and get the data
		if ( sorts != "" ) {
			// sorting operation
			qry &= " ORDER BY " & replace(replace(sorts, ":-1", " DESC", "all"), ":1", " ASC", "all");
		}
		// paging operation
		qry &= " LIMIT #offset#,#perPage#";

		var jData = queryRun(this.DATA_SOURCE, qry);

		// Create struct with Dynatree format
		var journals = {
			records: [],
			queryRecordCount: this.recordCount,
			totalRecordCount: perPage
		};

		// Add queried records to struct
		for ( var i = 1; i <= jData.recordCount; i++ ) {
			var rowData = queryRowStruct(jData, i);
			// Get the directories struct from parser
			rowData.coverage = new parser(this.JOURNAL_PATH & rowData.name).getAllFilesInDirectories();
			arrayAppend(journals.records, rowData);
		}

		return journals;
	}



	/**
		* Deletes journal file(s)
		*
		* @method purgeJournalData
		* @public
		* @param {string|list} _paths full path(s) to the journal file
		* @return {boolean}
		*/
	public boolean function purgeJournalsData( string _paths ) {
		var file;
		var ret = true;
		var whereClause = '';

		// Remove the files
		for ( var i = 1; i <= listLen(arguments._paths); i++ ) {
			fileName = listGetAt(arguments._paths, i);
			file = this.JOURNAL_PATH & fileName & '.session';
			whereClause &= ' OR name LIKE ''#fileName#''';

			try {
				if ( fileExists(file) ) {
					fileDelete(file);
				}

				ret = ret && fileDelete(this.JOURNAL_PATH & fileName);
			} catch( any e ){
				ret = false;
				console(serializeJSON(e));
			}
		}
		// remove first extra or
		whereClause = replace(whereClause, ' OR ', '');
		console(whereClause);

		if (ret) {
			// Remove data from the query
			queryRun(this.DATA_SOURCE, 'DELETE FROM #this.TABLE_NAME# WHERE #whereClause# ESCAPE ''~''');
		} else {
			// Force refresh
			queryRun(this.DATA_SOURCE, 'DROP TABLE #this.TABLE_NAME#');
		}

		return ret;
	}



	/**
		* Remote (AJAX) function for getting the latest journal files timestamp
		*
		* @method latestJournalTimestamp
		* @remote
		* @return {any}
		*/
	remote function latestJournalTimestamp() returnformat='plain' {
		var everything = directoryList( ArgumentCollection= {	path:GetJournalDirectory(),
																													recurse:true,
																													sort:'datelastmodified desc',
																													filter:'*.txt'} );
		if( arrayLen(everything) > 0 ) {
			return ListLast(everything[1], fileSeparator());
		} else {
			return 'none';
		}
	}
</cfscript></cfcomponent>