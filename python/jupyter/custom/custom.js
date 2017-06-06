require(["codemirror/keymap/sublime", "notebook/js/cell", "base/js/namespace"],
    function(sublime_keymap, cell, IPython) {
    	require("notebook/js/cell").Cell
        setTimeout(function(){ // uncomment line to fake race-condition
          require("notebook/js/cell").Cell.options_default.cm_config.keyMap = 'sublime';
          var cells = IPython.notebook.get_cells();
          for(var c=0; c<cells.length ; c++){
          	console.log( "Setting Sublime" )
              cells[c].code_mirror.setOption('keyMap', 'sublime');
          }

        }, 1000)// uncomment  line to fake race condition
    }
);
// "IPython.CodeCell.config_defaults.highlight_modes['magic_fortran'] = {};"
require(['notebook/js/codecell'], function(codecell) {
  codecell.CodeCell.options_default.highlight_modes['magic_fortran'] = {'reg':[/^%%fortran/]} ;
  console.log('AAAAA');
  Jupyter.notebook.events.one('kernel_ready.Kernel', function(){
      console.log('BBBBB');
      Jupyter.notebook.get_cells().map(function(cell){
          if (cell.cell_type == 'code'){ cell.auto_highlight(); } }) ;
  });
});
