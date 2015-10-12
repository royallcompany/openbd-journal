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
<cfset brw 		= new journal.browser()>
<cfset helper = new journal.helpers()>

<cfparam name = "URL.includes" default="">
<cfparam name = "URL.excludes" default="">

<!--- File option, deleting and compounding files --->
<cfif structKeyExists(form, "fileOption") AND structKeyExists(form, "fl")>
	<!--- Check the option chosen --->
	<cfif form.fileOption == "delete">
		<!--- Make sure the list is not empty --->
		<cfif Len(form.fl) GT 0>
			<cfloop list="#form.fl#" index="ind">
				<cfset brw.purgeJournal( getJournalDirectory() & '/' & ind)>
			</cfloop>
			<cfsavecontent variable="message"><cfoutput>
				<span style="color:green;">#ListLen(form.fl)# file<cfif ListLen(form.fl) GT 1>s</cfif> deleted.</span><br>
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

<cfinclude template="header.cfm">

	<cfinclude template="settings.cfm">

	<cfif isDefined('message')>
		<p><cfoutput>#message#</cfoutput></p>
	</cfif>

	<cfif (!structKeyExists(URL,"j"))>

	<h3 id="checkReload" style="visible:none;">&nbsp;</h3>

	<cfset browser = brw.queryAllJournals("","",true)>
	<form action="" method="post" class="pure-form">
		<table id="allJournals" border="0" cellspacing="0" class="pure-table pure-table-bordered pure-table-striped text-top">
			<thead>
				<tr>
					<th><input type="checkbox" id="checkAll" title="Select all"></th>
					<th>Journal</th>
					<th><label><input type="checkbox" id="files-control"> Show All Coverage Files</label></th>
					<th>Starting URI</th>
					<th>Created</th>
					<th>Output</th>
					<th>Size</th>
					<th>Time</th>
				</tr>
			</thead>
			<cfif (browser.recordCount > 0)>
			<cfloop query="browser"><cfoutput>
					<cfset journal = brw.getJournal(browser.directory & '/' & browser.name)>
					<tr>
						<td><input type="checkbox" class="journal-select" name="fl" value="#journal.relativeToJournal#"></td>
						<td>
							#journal.relativeToJournal#
							<cfif !left( journal.relativeToJournal, 9 ) == "/compound"><br><a href="code-trace.cfm?journal=#journal.relativeToJournal#" class="pure-button button-secondary" style="margin-top:0.5em">performance</a></cfif>
						</td>
						<td>
							<a href="coverage.cfm?journal=#journal.relativeToJournal#" class="pure-button button-warning coverage-btn" style="margin-bottom:0.5em">coverage</a><br>
							<a href="javascript:void(0);" class="directory-filtering-link">Filter by directory</a>
							<div class="<!--- hidden ---> directory-filtering">
								<fieldset>
									<legend>Filter as:</legend>
									<label class="pure-radio"><input type="radio" name="typeSwitch#journal.journalShort#" value="include" checked> include</label>
									<label class="pure-radio"><input type="radio" name="typeSwitch#journal.journalShort#" value="exclude"> exclude</label>
								</fieldset>
								<!--- Set the top parent's class and id of the directory tree --->
								#replace(replace(journal.getBrowsingTreeMarkup(journal.getAllFilesInDirectories()), "directory-list", "directory-list-master directory-list"), "<ul", '<ul id="' & journal.journalShort & '"')#
							</div>
						</td>
						<td>#listFirst(journal.info._uri,"?")#</td>
						<td>#DateFormat(journal.timestamp, "dd mmm")#, #TimeFormat(journal.timestamp, "hh:mm:ss tt")#</td>
						<td>#journal.info._bytes# bytes</td>
						<td>#helper.getNiceSizeFormat( journal.info._fileSize )#</td>
						<td>#journal.info._timems# ms</td>
					</tr>
			</cfoutput></cfloop>
			<cfelse>
				<tr><td colspan="9">There are no journal files. Use the form above to journal pages.</td></tr>
			</cfif>
			<tr>
				<td colspan="9">
					<div style="display:inline-block; vertical-align: middle; margin-right: 1em">
						<label class="pure-radio"><input type="radio" name="fileOption" value="delete"> Delete selected</label>
						<label class="pure-radio"><input type="radio" name="fileOption" value="compound" checked> Compound selected</label>
					</div>
					<input type="submit" value="Do it" class="pure-button pure-button-primary">
				</td>
			</tr>
		</table>
	</form>

	</cfif>

	<!--- Normal component version --->
	<script type="text/javascript">
	$( document ).ready( function() {
		// Toggle selection of all journals
		$( '#checkAll' ).on( 'click', function() {
			$( '.journal-select' ).prop( 'checked', this.checked );
		} );


		// Initialize browsing tree
		$( '.directory-list-master' ).a11yTree( {
			treeLabelId: 'files-control',
			treeItemLabelSelector: '.directory-label',
			toggleSelector: '.directory-toggle',
			toggleAllButton: true,
			onCollapse: function( $item, e ) {
				$item.children( '.directory-toggle' ).text( '+' );
				$item.find( 'ul.directory-list' ).addClass( 'hidden' );
			},
			onExpand: function( $item, e ) {
				$item.children( '.directory-toggle' ).text( '-' );
				$item.children( 'ul.directory-list' ).removeClass( 'hidden' );
			}
		} );


		// Directory browsing related buttons
		$('#files-control').on('click', function(e){
			var text = this.checked ? 'Expand all' : 'Collapse all';
			$('.at-toggle-all:contains('+text+')').trigger('click');
		})

		$('.directory-filtering-link').on('click', function(e){
			$(this).siblings('.directory-filtering').toggleClass('hidden');
		})


		// Browsing tree checkbox functionality
		$( '.directory-list-master input[type="checkbox"]' ).on( 'click', function(){
			var $parent,
				$cb = $( this ),
				isChecked = $cb.prop( 'checked' ),
				$parents = $cb.parentsUntil( '.directory-list-master', 'li' );

			// Set this cb as the endpoint for later
			$cb.addClass('endpoint');

			// Set all children
			$parents.eq( 0 ).find( 'ul input[type="checkbox"]' ).prop( {
				checked: isChecked,
				indeterminate: false
			} ).removeClass('endpoint');

			// Set all parents
			for ( var i = 0; i < $parents.length; i++ ) {
				$parent = $parents.eq( i );
				$parent.find( ' > label > input[type="checkbox"]' ).prop( {
					checked: isChecked,
					indeterminate: getDetermination( $parent )
				} );
			}
		});

		function getDetermination( $parent ) {
			var $inputs = $parent.find( 'ul input[type="checkbox"]' );

			if ( $inputs.is( ':not(:checked)' ) && $inputs.is( ':checked' ) ) {
				return true;
			} else {
				return false;
			}
		}


		// Add filtering param to coverage button link
		$('.coverage-btn').on('click', function(e){
			var $btn = $(this),
			$div = $btn.siblings('.directory-filtering').has('input[type="checkbox"]:checked'),
			filter = '&';

			// If user selected directories, build up the list
			if ( $div.length ) {
				// include or exclude
				filter += $btn.siblings('.directory-filtering').find('input:checked').val() + 's=';

				var $cbs = $('.endpoint');
				for (var i = 0; i < $cbs.length; i++) {
					filter += $cbs.eq(i).val() + ',';
				}
			}

			window.location.href = $btn.prop('href') + filter;

			return false;
		});


		// Poll for new journal files
		window.latestJournal = '';

		window.setInterval( function() {
			$.ajax( {
				url: 'journal/helpers.cfc?METHOD=latestJournalTimestamp',
				type: 'POST',
				dataType: 'HTML',
				success: function( i ) {
					if ( window.latestJournal.length == 0 ) {
						window.latestJournal = i;
					}

					if ( i != window.latestJournal ) {
						$( '#checkReload' ).html( '<a href="index.cfm" style="color:red;">There are new journal files, reload?</a>' ).show();
					}
				},
				error: function( a, b, c ) {
					console.log( 'Something went wrong when trying to look for new journal files' );
				}
			} );
		}, 4000 );
	} );
	</script>
<cfinclude template="footer.cfm">