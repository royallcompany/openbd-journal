$( document ).ready( function() {
	// Dynatable for AJAX sorting, paging
	$( '#allJournals' ).dynatable( {
		dataset: {
			ajax: true,
			ajaxUrl: 'journal/handler.cfc?METHOD=getJournalData',
			ajaxOnLoad: true,
			// ajaxMethod: 'POST',
			records: []
		},
		features: {
			search: false
		}
	} );

	// Toggle selection of all journals
	// $( '#checkAll' ).on( 'click', function() {
	// 	$( '.journal-select' ).prop( 'checked', this.checked );
	// } );


	// Initialize browsing tree
	// $( '.directory-list-master' ).a11yTree( {
	// 	treeLabelId: 'files-control',
	// 	treeItemLabelSelector: '.directory-label',
	// 	toggleSelector: '.directory-toggle',
	// 	toggleAllButton: true,
	// 	toggleAllClass: 'pure-button button-info',
	// 	onCollapse: function( $item, e ) {
	// 		$item.children( '.directory-toggle' ).text( '+' );
	// 		$item.find( 'ul.directory-list' ).addClass( 'hidden' );
	// 	},
	// 	onExpand: function( $item, e ) {
	// 		$item.children( '.directory-toggle' ).html( '&ndash;' );
	// 		$item.children( 'ul.directory-list' ).removeClass( 'hidden' );
	// 	}
	// } );


	// // Directory browsing related buttons
	// $( '#files-control' ).on( 'click', function( e ) {
	// 	var text = 'Expand all',
	// 		search = '.hidden';

	// 	if ( !this.checked ) {
	// 		text = 'Collapse all';
	// 		search = ':not(' + search + ')';
	// 	}

	// 	$( '.at-toggle-all:contains(' + text + ')' ).trigger( 'click' );
	// 	$( '.directory-filtering' + search ).siblings( '.directory-filtering-link' ).trigger( 'click' );
	// } );

	// $( '.directory-filtering-link' ).on( 'click', function( e ) {
	// 	$( this ).toggleClass('dropdown-open dropdown-close').siblings( '.directory-filtering' ).toggleClass( 'hidden' );
	// } );


	// // Browsing tree checkbox functionality
	// $( '.directory-list-master input[type="checkbox"]' ).on( 'click', function() {
	// 	var $parent,
	// 		$cb = $( this ),
	// 		isChecked = $cb.prop( 'checked' ),
	// 		$parents = $cb.parentsUntil( '.directory-list-master', 'li' );

	// 	// Set all children
	// 	$parents.eq( 0 ).find( 'ul input[type="checkbox"]' ).prop( {
	// 		checked: isChecked,
	// 		indeterminate: false
	// 	} );

	// 	// Set all parents
	// 	for ( var i = 0; i < $parents.length; i++ ) {
	// 		$parent = $parents.eq( i );
	// 		$parent.find( ' > label > input[type="checkbox"]' ).prop( {
	// 			checked: isChecked,
	// 			indeterminate: getDetermination( $parent )
	// 		} );
	// 	}
	// } );

	// function getDetermination( $parent ) {
	// 	var $inputs = $parent.find( 'ul input[type="checkbox"]' );

	// 	if ( $inputs.is( ':not(:checked)' ) && $inputs.is( ':checked' ) ) {
	// 		return true;
	// 	} else {
	// 		return false;
	// 	}
	// }


	// // Add filtering param to coverage button link
	// $( '.coverage-btn' ).on( 'click', function( e ) {
	// 	var $btn = $( this ),
	// 		$div = $btn.siblings( '.directory-filtering' ).has( 'input[type="checkbox"]:checked' ),
	// 		filter = [];

	// 	// If user selected directories, build up the list
	// 	if ( $div.length ) {
	// 		var i, $cb,
	// 			$cbs = $div.find( 'input[type="checkbox"]:checked' );

	// 		// Go through all the checked inputs and add unique directories to filter
	// 		for ( i = 0; i < $cbs.length; i++ ) {
	// 			$cb = $cbs.eq( i );

	// 			if ( !$cb.prop( 'indeterminate' ) && notInDirectoryFilter( filter, $cb.val() ) ) {
	// 				filter.push( $cb.val() + '/' );
	// 			}
	// 		}

	// 		// include or exclude
	// 		filter = '&' + $btn.siblings( '.directory-filtering' ).find( 'input:checked' ).val() + 's=' + filter;
	// 	}

	// 	window.location.href = $btn.prop( 'href' ) + filter;

	// 	return false;
	// } );

	// function notInDirectoryFilter( arr, str ) {
	// 	var i,
	// 		check = '',
	// 		separated = str.split( '/' );

	// 	for ( i = 0; i < separated.length; i++ ) {
	// 		check = check + separated[ i ] + '/';

	// 		if ( arr.indexOf( check ) >= 0 ) {
	// 			return false;
	// 		}
	// 	}

	// 	return true;
	// }
} );
