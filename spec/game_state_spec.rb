describe Freecell::GameState do
  let(:h4) { Freecell::Card.new(4, :hearts) }
  let(:h3) { Freecell::Card.new(3, :hearts) }
  let(:h2) { Freecell::Card.new(2, :hearts) }
  let(:h1) { Freecell::Card.new(1, :hearts) }

  let(:s3) { Freecell::Card.new(3, :spades) }
  let(:s2) { Freecell::Card.new(2, :spades) }
  let(:s1) { Freecell::Card.new(1, :spades) }

  def expect_card(card, rank, suit)
    expect(card.rank).to eq(rank)
    expect(card.suit).to eq(suit)
  end

  describe '#initialize' do
    let(:game_state) do
      Freecell::GameState.new
    end
    it 'creates the correct game regions' do
      expect(game_state.cascades.count).to eq(8)
      expect(game_state.foundations.keys.count).to eq(4)
      expect(game_state.free_cells.count).to eq(0)
    end
  end

  describe '#apply' do
    context 'when moving between cascades' do
      let(:game_state) do
        cascades = [
          [s3],
          [h4]
        ]
        Freecell::GameState.new(cascades)
      end

      before do
        cmd = Freecell::GameStateCommand.new(
          type: :cascade_to_cascade,
          source_index: 0,
          dest_index: 1
        )
        game_state.apply(cmd)
      end

      subject do
        game_state.cascades[1]
      end

      it 'allows legal moves' do
        expect(subject.length).to eq(2)
        expect_card(subject[0], 4, :hearts)
        expect_card(subject[1], 3, :spades)
      end
    end

    context 'when moving to free cells' do
      let(:game_state) do
        cascades = [
          [h4, h3, h2, h1, s3]
        ]
        Freecell::GameState.new(cascades)
      end

      before do
        cmd = Freecell::GameStateCommand.new(
          type: :cascade_to_free_cell,
          source_index: 0
        )
        game_state.apply(cmd)
        game_state.apply(cmd)
        game_state.apply(cmd)
        game_state.apply(cmd)
        game_state.apply(cmd)
      end

      subject do
        game_state.free_cells
      end

      it 'allows legal moves' do
        expect(subject.length).to eq(4)
        expect(game_state.cascades[0].length).to eq(1)
        expect_card(subject[0], 3, :spades)
        expect_card(subject[1], 1, :hearts)
        expect_card(subject[2], 2, :hearts)
        expect_card(subject[3], 3, :hearts)
      end
    end

    context 'when moving to foundations from cascades' do
      let(:game_state) do
        cascades = [
          [h4],
          [s3]
        ]
        foundations = {
          hearts: [h3], diamonds: [],
          clubs: [], spades: [s1]
        }
        Freecell::GameState.new(cascades, nil, foundations)
      end

      before do
        cmd1 = Freecell::GameStateCommand.new(
          type: :cascade_to_foundation,
          source_index: 0
        )
        cmd2 = Freecell::GameStateCommand.new(
          type: :cascade_to_foundation,
          source_index: 1
        )
        game_state.apply(cmd1)
        game_state.apply(cmd2)
      end

      subject do
        game_state.foundations
      end

      it 'applies legal moves' do
        expect(game_state.cascades[0].count).to eq(0)
        expect(subject[:hearts].count).to eq(2)
        expect_card(subject[:hearts].last, 4, :hearts)
      end

      it 'doesn\'t apply illegal moves' do
        expect(game_state.cascades[1].count).to eq(1)
        expect(subject[:spades].count).to eq(1)
      end
    end

    context 'when moving to foundations from free cells' do
      let(:game_state) do
        free_cells = [h2, s2]
        foundations = {
          hearts: [h1],
          spades: []
        }
        Freecell::GameState.new(nil, free_cells, foundations)
      end

      before do
        cmd = Freecell::GameStateCommand.new(
          type: :free_cell_to_foundation,
          source_index: 0
        )
        game_state.apply(cmd)
        game_state.apply(cmd)
      end

      it 'moves a valid card to its foundation' do
        expect(game_state.foundations[:hearts].count).to eq(2)
        expect_card(game_state.foundations[:hearts].last, 2, :hearts)
      end

      it 'doesn\t move an invalid card' do
        expect(game_state.foundations[:spades].count).to eq(0)
      end
    end

    context 'when moving to cascades from free cells' do
      let(:game_state) do
        free_cells = [h2]
        cascades = [
          [s3]
        ]
        Freecell::GameState.new(cascades, free_cells)
      end

      before do
        cmd = Freecell::GameStateCommand.new(
          type: :free_cell_to_cascade,
          source_index: 0,
          dest_index: 0
        )
        game_state.apply(cmd)
      end

      it 'moves the card to the cascade' do
        expect(game_state.cascades[0].count).to eq(2)
        expect_card(game_state.cascades[0].last, 2, :hearts)
      end
    end

    context 'when saving the currently selected free cell card' do
      let(:game_state) do
        free_cells = [
          s3,
          h4
        ]
        Freecell::GameState.new(nil, free_cells)
      end
      before do
        cmd = Freecell::GameStateCommand.new(
          type: :free_cell_selection,
          source_index: 1
        )
        game_state.apply(cmd)
      end

      it 'saves the card' do
        expect(game_state.selected_card).to eq(h4)
      end
    end

    context 'when saving the currently selected cascade card' do
      let(:game_state) do
        cascades = [
          [s3],
        ]
        Freecell::GameState.new(cascades)
      end
      before do
        cmd = Freecell::GameStateCommand.new(
          type: :cascade_selection,
          source_index: 0
        )
        game_state.apply(cmd)
      end

      it 'saves the card' do
        expect(game_state.selected_card).to eq(s3)
      end
    end

    context 'when applying a reset command' do
      let(:game_state) do
        cascades = [
          [s3],
        ]
        Freecell::GameState.new(cascades)
      end
      before do
        selection_cmd = Freecell::GameStateCommand.new(
          type: :cascade_selection,
          source_index: 0
        )
        reset_cmd = Freecell::GameStateCommand.new(
          type: :state_reset
        )
        game_state.apply(selection_cmd)
        game_state.apply(reset_cmd)
      end

      it 'removes the saved selected card' do
        expect(game_state.selected_card).to be_nil
      end
    end
  end
end
