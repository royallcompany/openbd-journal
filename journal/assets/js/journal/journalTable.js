$( document ).ready( function() {
	// Dynatable for AJAX sorting, paging
	$( '#allJournals' ).dynatable( {
		dataset: {
			ajax: true,
			ajaxUrl: 'journal/handler.cfc?METHOD=getJournalsData',
			ajaxOnLoad: true,
			// ajaxMethod: 'POST',
			records: []
		},
		features: {
			search: false
		},
		writers: {
			_attributeWriter: customAttrWriter
		}
	} ).on( 'dynatable:afterUpdate', bindEventsToTable );


	function customAttrWriter( record ) {
		switch ( this.id ) {
			case 'SELECTCB':
				return '<input type="checkbox" class="journal-select" name="fl" value="' + record.NAME + '">';
			case 'coverage':
				var markup = $( '#coverage-template' ).html() + getCoverageMarkup( record.coverage );
				// RESUME get -master class on directory

				return markup.replace( /\{\{([A-z]+)\}\}/g, function() {
					// Replace "dropins" with the record result
					if ( record[ arguments[ 1 ] ] ) {
						return record[ arguments[ 1 ] ];
					}
					return '';
				} );
			case 'CREATED':
				record.CREATED = new Date( record.CREATED );
				break;
			case 'SIZE':
				record.SIZE = getNiceSizeFormat( record.SIZE );
				break;
		}
		return record[ this.id ];
	}



	function getNiceSizeFormat( bytes ) {
		var ret = '';

		if ( bytes >= 1073741824 ) {
			ret = ( bytes / 1073741824 ).toFixed(1) + ' GB';
		} else if ( bytes >= 1048576 ) {
			ret = ( bytes / 1048576 ).toFixed(1) + ' MB';
		} else if ( bytes >= 1024 ) {
			ret = ( bytes / 1024 ).toFixed(1) + ' kB';
		} else {
			ret = '1> kB';
		}
		return ret;
	}


	function getCoverageMarkup( cov, prefix ) {
		var list = $( '<ul></ul>' );
		prefix = prefix || '';

		if ( cov && typeof cov === 'object' ) {
			// Objects: ol > li > ol
			if ( !cov.splice ) {
				// create the list
				list.addClass( 'directory-list' );

				// create list items
				for ( var d in cov ) {
					if ( cov.hasOwnProperty( d ) ) {
						if ( !cov[ d ].splice ) {
							// revert clean up the path for struct
							var val = d.replace( 'NUM_BER_', '' ).replace( '_DASH_HERE_', '-' );

							// insert the list item
							list.append( '<li class="directory-item"><span class="directory-toggle">-</span><label class="pure-checkbox"><input type="checkbox" value="' + prefix + val + '"><span class="directory-label">' + val + '</span></label></li>' );
							// insert next directory list
							list.find( 'li:last' ).append( getCoverageMarkup( cov[ d ], prefix + val + '/' ) );
						} else {
							// file list
							list.prepend( '<li></li>' ).find( 'li:first' ).append( getCoverageMarkup( cov[ d ] ) );
						}
					}
				}
			}
			// Arrays: ul > li
			else {
				// create the list
				list.addClass( 'file-list' );

				// create list items
				for ( var i = 0; i < cov.length; i++ ) {
					list.append( '<li class="file-item"><a href="fileCoverage.cfm?journal={{NAME}}&file=' + cov[ i ].id + '">' + cov[ i ].name + '</a></li>' );
				}
			}
		}

		return list[ 0 ].outerHTML;
	}


	function bindEventsToTable() {
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
			toggleAllClass: 'pure-button button-info',
			onCollapse: function( $item, e ) {
				$item.children( '.directory-toggle' ).text( '+' );
				$item.find( 'ul.directory-list' ).addClass( 'hidden' );
			},
			onExpand: function( $item, e ) {
				$item.children( '.directory-toggle' ).html( '&ndash;' );
				$item.children( 'ul.directory-list' ).removeClass( 'hidden' );
			}
		} );


		// Directory browsing related buttons
		$( '#files-control' ).on( 'click', function( e ) {
			var text = 'Expand all',
				search = '.hidden';

			if ( !this.checked ) {
				text = 'Collapse all';
				search = ':not(' + search + ')';
			}

			$( '.at-toggle-all:contains(' + text + ')' ).trigger( 'click' );
			$( '.directory-filtering' + search ).siblings( '.directory-filtering-link' ).trigger( 'click' );
		} );

		$( '.directory-filtering-link' ).on( 'click', function( e ) {
			$( this ).toggleClass( 'dropdown-open dropdown-close' ).siblings( '.directory-filtering' ).toggleClass( 'hidden' );
		} );


		// Browsing tree checkbox functionality
		$( '.directory-list-master input[type="checkbox"]' ).on( 'click', function() {
			var $parent,
				$cb = $( this ),
				isChecked = $cb.prop( 'checked' ),
				$parents = $cb.parentsUntil( '.directory-list-master', 'li' );

			// Set all children
			$parents.eq( 0 ).find( 'ul input[type="checkbox"]' ).prop( {
				checked: isChecked,
				indeterminate: false
			} );

			// Set all parents
			for ( var i = 0; i < $parents.length; i++ ) {
				$parent = $parents.eq( i );
				$parent.find( ' > label > input[type="checkbox"]' ).prop( {
					checked: isChecked,
					indeterminate: getDetermination( $parent )
				} );
			}
		} );

		function getDetermination( $parent ) {
			var $inputs = $parent.find( 'ul input[type="checkbox"]' );

			if ( $inputs.is( ':not(:checked)' ) && $inputs.is( ':checked' ) ) {
				return true;
			} else {
				return false;
			}
		}


		// Add filtering param to coverage button link
		$( '.coverage-btn' ).on( 'click', function( e ) {
			var $btn = $( this ),
				$div = $btn.siblings( '.directory-filtering' ).has( 'input[type="checkbox"]:checked' ),
				filter = [];

			// If user selected directories, build up the list
			if ( $div.length ) {
				var i, $cb,
					$cbs = $div.find( 'input[type="checkbox"]:checked' );

				// Go through all the checked inputs and add unique directories to filter
				for ( i = 0; i < $cbs.length; i++ ) {
					$cb = $cbs.eq( i );

					if ( !$cb.prop( 'indeterminate' ) && notInDirectoryFilter( filter, $cb.val() ) ) {
						filter.push( $cb.val() + '/' );
					}
				}

				// include or exclude
				filter = '&' + $btn.siblings( '.directory-filtering' ).find( 'input:checked' ).val() + 's=' + filter;
			}

			window.location.href = $btn.prop( 'href' ) + filter;

			return false;
		} );

		function notInDirectoryFilter( arr, str ) {
			var i,
				check = '',
				separated = str.split( '/' );

			for ( i = 0; i < separated.length; i++ ) {
				check = check + separated[ i ] + '/';

				if ( arr.indexOf( check ) >= 0 ) {
					return false;
				}
			}

			return true;
		}
	}


	// Poll for new journal files
	var latestJournal = '';

	setInterval( function() {
		$.ajax( {
			url: 'journal/handler.cfc?METHOD=latestJournalTimestamp',
			type: 'POST',
			dataType: 'HTML',
			success: function( i ) {
				if ( latestJournal.length === 0 ) {
					latestJournal = i;
				}

				if ( i !== latestJournal ) {
					$( '#messageP' ).append( '<a href="index.cfm" style="color:red;">There are new journal files, reload?</a>' );
				}
			},
			error: function( a, b, c ) {
				console.log( 'Something went wrong when trying to look for new journal files' );
			}
		} );
	}, 4000 );
} );