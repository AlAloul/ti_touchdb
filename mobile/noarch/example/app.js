// open a single window
var window = Ti.UI.createWindow({
  layout: 'vertical',
	backgroundColor:'white'
});

var testname = Ti.UI.createLabel();
window.add(testname);

var status = Ti.UI.createLabel();
window.add(status);

var imageView = Ti.UI.createImageView();
window.add(imageView);

window.addEventListener('open', function() {
  Ti.API.info("starting tests");
    try {
      /*
      testname.text = '001_module';
      require('001_module').run_tests();
      testname.text = '002_databaseManager';
      require('002_databaseManager').run_tests();
      testname.text = '003_database';
      require('003_database').run_tests();
      testname.text = '004_database_query';
      require('004_database_query').run_tests();
      testname.text = '005_database_validation';
      require('005_database_validation').run_tests();
      testname.text = '006_document';
      require('006_document').run_tests();
      testname.text = '007_revisions';
      require('007_revisions').run_tests();
      testname.text = '008_attachments';
      require('008_attachments').run_tests();
      testname.text = '009_views';
      require('009_views').run_tests();
      testname.text = '010_change_tracking';
      require('010_change_tracking').run_tests();
      testname.text = '011_update_in_query';
      require('011_update_in_query').run_tests();
      testname.text = '012_history';
      require('012_history').run_tests();
      */
      testname.text = '013_view_linked_docs';
      require('013_view_linked_docs').run_tests();


      /*
        testname.text = 'test01_server';
        require('test01_server').run_tests();
        testname.text = 'test02_createdocument';
        require('test02_createdocument').run_tests();
        testname.text = 'test02_createrevisions';
        require('test02_createrevisions').run_tests();
        testname.text = 'test03_savemultipledocuments';
        require('test03_savemultipledocuments').run_tests();
        testname.text = 'test03_savemultipleunsaveddocuments';
        require('test03_savemultipleunsaveddocuments').run_tests();
        testname.text = 'test03_deletemultipledocuments';
        require('test03_deletemultipledocuments').run_tests();
        testname.text = 'test03_bulk_save';
        require('test03_bulk_save').run_tests();
        testname.text = 'test04_deletedocument';
        require('test04_deletedocument').run_tests();
        testname.text = 'test05_alldocuments';
        require('test05_alldocuments').run_tests();
        testname.text = 'test05_updatefromalldocs';
        require('test05_updatefromalldocs').run_tests();
        testname.text = 'test07_history';
        require('test07_history').run_tests();
        testname.text = 'test08_attachments';
        require('test08_attachments').run_tests();
        testname.text = 'test12_createview';
        require('test12_createview').run_tests();
        testname.text = 'test13_runview';
        require('test13_runview').run_tests();
        testname.text = 'test13_viewreduce';
        require('test13_viewreduce').run_tests();
        testname.text = 'test13_viewcomplexkeys';
        require('test13_viewcomplexkeys').run_tests();
        testname.text = 'test13_validation';
        require('test13_validation').run_tests();
        testname.text = 'test13_viewupdate';
        require('test13_viewupdate').run_tests();
        testname.text = 'test14_runslowview';
        require('test14_runslowview').run_tests();
        testname.text = 'test14_viewwithlinkeddocs';
        require('test14_viewwithlinkeddocs').run_tests();
        testname.text = 'test15_uncacheviews';
        require('test15_uncacheviews').run_tests();
        testname.text = 'test16_viewoptions';
        require('test16_viewoptions').run_tests();
        testname.text = 'test17_replication';
        require('test17_replication').run_tests();
        testname.text = 'test18_filters';
        require('test18_filters').run_tests();
        */
        testname.text = "all tests passed! whoopee!";
    }
    catch (e) {
        status.text = e;
    }
});

window.open();


