require 'Qt'
require 'tictactoe/game'
require 'tictactoe/players/factory'
require 'tictactoe/players/perfect_computer'
require 'tictactoe/gui/game_updater'
require 'tictactoe/gui/qtgui/game_gui'
require 'tictactoe/gui/qtgui/menu_gui'
require 'tictactoe/gui/qtgui/widgets/factory'
require 'tictactoe/gui/human_player'

module Tictactoe
  module Gui
    class Runner
      def initialize(framework = QtGui::Widgets::Factory.new)
        self.framework = framework
        show_windows
      end

      def run
        framework.start_event_loop
      end

      private
      attr_accessor :framework
      attr_accessor :menu_window

      def show_windows
        self.menu_window = create_menu_window
        menu_window.show
      end

      def create_menu_window
        menu_window = QtGui::MenuGui.new(framework)
        menu_window.on_configured(method(:show_game))

        menu_window
      end

      def show_game(options)
        create_game_window(options).show
      end

      def create_game_window(options)
        game_gui = create_game_gui(options)
        game = create_game(game_gui, options)

        Gui::GameUpdater.new(game, game_gui).receive_ticks_from(game_gui)

        game_gui
      end

      def create_game_gui(options)
        game_gui = QtGui::GameGui.new(framework, options[:board])
        game_gui.on_play_again(lambda{menu_window.show})

        game_gui
      end

      def create_game(game_gui, options)
        Tictactoe::Game.new(players_factory(game_gui), options[:board], options[:x], options[:o])
      end

      def players_factory(game_gui)
        factory = Tictactoe::Players::Factory.new
        factory.register(:computer, lambda { |mark| Tictactoe::Players::PerfectComputer.new(mark) })
        factory.register(:human, lambda { |mark| HumanPlayer.new(mark).receive_moves_from(game_gui) })
        factory
      end
    end
  end
end
