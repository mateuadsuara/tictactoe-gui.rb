require 'Qt'

module Tictactoe
  module Gui
    module QtGui
      module Widgets
        class Window
          attr_reader :root
          attr_reader :layout

          def initialize(width, height)
            @root = Qt::Widget.new()
            @root.object_name = "main_window"
            @root.resize(width, height)
            @layout = create_main_layout(@root)
          end

          def close
            @root.close
          end

          def show
            @root.show
          end

          private
          def create_main_layout(parent)
            main_layout = Qt::GridLayout.new(parent)
            main_layout.object_name = "main_layout"
            main_layout
          end
        end
      end
    end
  end
end