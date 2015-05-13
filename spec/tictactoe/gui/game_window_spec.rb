require 'spec_helper'
require 'tictactoe/gui/game_window'
require 'tictactoe/gui/qtgui/factory'

RSpec.describe Tictactoe::Gui::GameWindow, :integration => true, :gui => true do
  before(:each) do
    Qt::Application.new(ARGV)
  end

  def create(ttt)
    qt_factory = Tictactoe::Gui::QtGui::WidgetFactory.new()
    game_window = described_class.new(qt_factory, ttt, 3, lambda{|game, selection|})
    qt_window = qt_factory.window.root
    {:game => game_window, :qt => qt_window}
  end

  it 'is a widget' do
    gui = create(spy())[:qt]
    expect(gui).to be_kind_of(Qt::Widget)
    expect(gui.parent).to be_nil
    expect(gui.object_name).to eq("main_window")
  end

  RSpec::Matchers.define :have_widged_named do |expected|
    match do |widget|
      widget.children.any? do |child|
        child.object_name == expected
      end
    end
  end

  def find_cell(gui, index)
    find(gui, "cell_#{index}")
  end

  def expect_to_have_cell(gui, index)
    expect(gui).to have_widged_named "cell_#{index}"
  end

  def expect_result_text(gui, text)
    expect(find(gui, 'result').text).to eq(text)
  end

  it 'has the board cells' do
    tictactoe = spy(:marks => [
      nil, nil, nil,
      nil, nil, nil,
      nil, nil, nil
    ])
    gui = create(tictactoe)[:qt]
    (0..8).each do |index|
      expect_to_have_cell(gui, index)
    end
  end

  (0..8).each do |index|
    it "when cell #{index} is clicked, interacts with tictactoe" do
      tictactoe = spy()
      gui = create(tictactoe)[:qt]
      find_cell(gui, index).click
      expect(tictactoe).to have_received(:tick)
    end
  end

  describe 'after a move, displays the mark in the cell' do
    it 'in cell 0' do
      tictactoe = spy(:marks => [
        :x,  nil, nil,
        nil, nil, nil,
        nil, nil, nil
      ])
      gui = create(tictactoe)[:qt]
      cell = find_cell(gui, 0)
      cell.click
      expect(cell.text).to eq('x')
    end

    it 'in cell 6' do
      tictactoe = spy(:marks => [
        nil, nil, nil,
        nil, nil, nil,
        :x,  nil, nil
      ])
      gui = create(tictactoe)[:qt]
      cell = find_cell(gui, 6)
      cell.click
      expect(cell.text).to eq('x')
    end
  end

  it 'has the result widget' do
    gui = create(spy())[:qt]
    expect(gui).to have_widged_named("result")
  end

  describe 'after a move shows the result' do
    it 'unless it is not finished' do
      tictactoe = spy({
        :marks => [],
        :is_finished? => false,
      })
      gui = create(tictactoe)[:qt]
      find_cell(gui, 0).click
      expect_result_text(gui, nil)
    end

    it 'of winner x' do
      tictactoe = spy({
        :marks => [],
        :is_finished? => true,
        :winner => :x,
      })
      gui = create(tictactoe)[:qt]
      find_cell(gui, 0).click
      expect_result_text(gui, 'Player X has won.')
    end

    it 'of winner o' do
      tictactoe = spy({
        :marks => [],
        :is_finished? => true,
        :winner => :o,
      })
      gui = create(tictactoe)[:qt]
      find_cell(gui, 0).click
      expect_result_text(gui, 'Player O has won.')
    end

    it 'of a draw' do
      tictactoe = spy({
        :marks => [],
        :is_finished? => true,
        :winner => nil,
      })
      gui = create(tictactoe)[:qt]
      find_cell(gui, 0).click
      expect_result_text(gui, 'It is a draw.')
    end
  end

  describe 'the timer' do
    it 'exists' do
      gui = create(spy())[:qt]
      expect(gui).to have_widged_named 'timer'
      expect(find(gui, 'timer')).to be_an_instance_of Qt::Timer
    end

    it 'has the shortest update interval' do
      gui = create(spy())[:qt]
      expect(find(gui, 'timer').interval).to eq(0)
    end

    it 'is active after showing the window' do
      gui = create(spy())
      gui[:game].show
      expect(find(gui[:qt], 'timer').active).to eq(true)
    end

    it 'is stopped after closing the window' do
      gui = create(spy())
      gui[:game].close
      expect(find(gui[:qt], 'timer').active).to eq(false)
    end

    describe 'when timing out' do
      it 'calls tick on tictactoe' do
        tictactoe = spy()
        gui = create(tictactoe)[:qt]

        expect(tictactoe).not_to have_received(:tick)
        find(gui, 'timer').timeout
        expect(tictactoe).to have_received(:tick)
      end

      it 'updates the board' do
        tictactoe = spy(:marks => [
          :x,  nil, nil,
          nil, nil, nil,
          nil, nil, nil
        ])
        gui = create(tictactoe)[:qt]
        find(gui, 'timer').timeout

        expect(find_cell(gui, 0).text).to eq('x')
      end
    end
  end
end
