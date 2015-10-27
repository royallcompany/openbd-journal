<!---
	OpenBD Journaling Tool
  Copyright (C) 2015

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfset title 	= 'Journal Files'>

<!--- File option, deleting and compounding files --->
<cfif structKeyExists(form, "fileOption") AND structKeyExists(form, "fl")>
	<!--- Check the option chosen --->
	<cfif form.fileOption == "delete">
		<!--- Make sure the list is not empty --->
		<cfif Len(form.fl) GT 0>
			<cfset result = createObject("journal/handler").purgeJournalsData(form.fl)>

				<cfsavecontent variable="message"><cfoutput>
					<cfif result == true>
						<span style="color:green;">#ListLen(form.fl)# file<cfif ListLen(form.fl) GT 1>s</cfif> deleted.</span><br>
					<cfelse>
						<span style="color:red;">Failed to delete.</span><br>
					</cfif>
				</cfoutput></cfsavecontent>
		</cfif>

	<cfelseif form.fileOption == "compound">
		<!--- Make sure the list contains at least two files --->
		<cfif listLen(form.fl) GT 1>
			<cfset cmp 				= CreateObject("component", "journal.compound")>
			<cfset list 			= listToArray( listSort(form.fl, "text") )>
			<cfset compStatus = cmp.compoundJournals( _files = form.fl )>
			<cfif compStatus._success>
				<cfsavecontent variable="message"><span style="color:green;">Files compounded!</span></cfsavecontent>
			<cfelse>
				<cfsavecontent variable="message"><span style="color:red;">Compound failed!</span></cfsavecontent>
			</cfif>
		<cfelse>
			<cfsavecontent variable="message"><span style="color:red;">To create a compound file, you need to select a start and end file.</span></cfsavecontent>
		</cfif>
	<cfelse>

		<cfsavecontent variable="message">I've no idea how you managed to get to the else switch, go you!</cfsavecontent>
	</cfif>
</cfif>

<cfinclude template="includes/header.cfm">

	<cfinclude template="includes/settings.cfm">

	<cfif (!structKeyExists(URL,"j"))>

	<p id="messageP"><cfif isDefined('message')>
		<cfoutput>#message#</cfoutput>
	</cfif></p>

	<form action="" method="post" class="pure-form">
		<table id="allJournals" border="0" cellspacing="0" class="pure-table pure-table-bordered pure-table-striped text-top">
			<thead>
				<tr>
					<th data-dynatable-column="SELECTCB" data-dynatable-no-sort="true"><input type="checkbox" id="checkAll" title="Select all"></th>
					<th data-dynatable-column="NAME">Journal</th>
					<th data-dynatable-column="coverage" data-dynatable-no-sort="true"><label><input type="checkbox" id="files-control"> Show All Coverage Files</label></th>
					<th data-dynatable-column="STARTINGURI">Starting URI</th>
					<th data-dynatable-column="CREATED">Created</th>
					<th data-dynatable-column="OUTPUT">Output</th>
					<th data-dynatable-column="SIZE">Size</th>
					<th data-dynatable-column="TIME">Time</th>
				</tr>
			</thead>
			<tbody></tbody>
		</table>
	</form>

	<script id="end-row-template" type="text/template">
				<tr>
					<td colspan="9">
						<div style="display:inline-block; vertical-align: middle; margin-right: 1em">
							<label class="pure-radio"><input type="radio" name="fileOption" value="delete"> Delete selected</label>
							<label class="pure-radio"><input type="radio" name="fileOption" value="compound" checked> Compound selected</label>
						</div>
						<input type="submit" value="Do it" class="pure-button pure-button-primary">
					</td>
				</tr>
	</script>

	<script id="empty-template" type="text/template">
				<tr><td colspan="9">There are no journal files. Use the form above to create journals.</td></tr>
	</script>

	<script id="coverage-template" type="text/template">
				<a href="coverage.cfm?journal={{NAME}}" class="pure-button button-warning coverage-btn" style="margin-bottom:0.5em">coverage</a>
  			<br><a href="javascript:void(0);" class="directory-filtering-link dropdown-open">Filter by directory</a>
  			<div class="hidden directory-filtering">
	  			<fieldset>
		  			<legend>Filter as:</legend>
		  			<label class="pure-radio"><input type="radio" name="typeSwitch{{SHORTNAME}}" value="include" checked> include</label>
		  			<label class="pure-radio"><input type="radio" name="typeSwitch{{SHORTNAME}}" value="exclude"> exclude</label>
	  			</fieldset>
  			</div>
	</script>

	<script id="directories-template" type="text/template">
					<li class="directory-item">
						<span class="directory-toggle">-</span>
						<label class="pure-checkbox">
							<input type="checkbox" value="{{prefix}}{{dir}}">
							<span class="directory-label">{{dir}}</span>
						</label>
					</li>
	</script>

	<script id="files-template" type="text/template">
				<ul class="file-list">
					<li class="file-item"><a href="fileCoverage.cfm?journal={{SHORTNAME}}&file={{id}}">{{name}}</a></li>
				</ul>
	</script>

	</cfif>

	<script src="assets/js/journal/journalTable.js"></script> <!--- contains necessary javascript for this page --->

<cfinclude template="includes/footer.cfm">