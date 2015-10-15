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

<cfinclude template="header.cfm">

	<cfinclude template="settings.cfm">

	<cfif (!structKeyExists(URL,"j"))>

	<p id="messageP"></p>

	<cfset handler = new journal.handler()>

	<form action="" method="post" class="pure-form">
		<table id="allJournals" border="0" cellspacing="0" class="pure-table pure-table-bordered pure-table-striped text-top">
			<thead>
				<tr>
					<th data-dynatable-no-sort="true"><input type="checkbox" id="checkAll" title="Select all"></th>
					<th data-dynatable-column="NAME">Journal</th>
					<th data-dynatable-no-sort="true"><label><input type="checkbox" id="files-control"> Show All Coverage Files</label></th>
					<th data-dynatable-column="STARTINGURI">Starting URI</th>
					<th data-dynatable-column="CREATED">Created</th>
					<th data-dynatable-column="OUTPUT">Output</th>
					<th data-dynatable-column="SIZE">Size</th>
					<th data-dynatable-column="TIME">Time</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td colspan="9">
						<div style="display:inline-block; vertical-align: middle; margin-right: 1em">
							<label class="pure-radio"><input type="radio" name="fileOption" value="delete"> Delete selected</label>
							<label class="pure-radio"><input type="radio" name="fileOption" value="compound" checked> Compound selected</label>
						</div>
						<input type="submit" value="Do it" class="pure-button pure-button-primary">
					</td>
				</tr>
			</tbody>
		</table>
	</form>

	</cfif>

	<script src="assets/js/journal/journalTable.js"></script> d
<cfinclude template="footer.cfm">