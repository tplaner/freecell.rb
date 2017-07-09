describe Freecell::InputStateMachine do
  describe '#handle_ch' do
    let(:sm) do
      Freecell::InputStateMachine.new
    end

    context 'when input is invalid' do
      subject do
        sm
      end

      before do
        sm.handle_ch('i')
        sm.handle_ch('a')
        sm.handle_ch('i')
      end

      it 'returns to the empty state' do
        expect(subject.state).to eq('empty')
        expect(subject.source_index).to be_nil
        expect(subject.dest_index).to be_nil
      end
    end

    context 'when input should move between cascades' do
      before do
        sm.handle_ch('b')
      end

      subject do
        sm.handle_ch('c')
      end

      it 'returns the correct move' do
        expect(subject).to eq({ type: :move, value: [:cascade_to_cascade, 1, 2] })
      end
    end

    context 'when input should move from cascade to free cell' do
      before do
        sm.handle_ch('d')
      end

      subject do
        sm.handle_ch(' ')
      end

      it 'returns the correct move' do
        expect(subject).to eq({ type: :move, value: [:cascade_to_free_cell, 3] })
      end
    end

    context 'when input should move from free cell to cascade' do
      before do
        sm.handle_ch('y')
      end

      subject do
        sm.handle_ch('c')
      end

      it 'returns the correct move' do
        expect(subject).to eq({ type: :move, value: [:free_cell_to_cascade, 2, 2] })
      end
    end

    context 'when input should move from cascade to foundation' do
      before do
        sm.handle_ch('h')
      end

      subject do
        sm.handle_ch(Freecell::CharacterParser::CARRIAGE_RETURN_BYTE)
      end

      it 'returns the correct move' do
        expect(subject).to eq({ type: :move, value: [:cascade_to_foundation, 7] })
      end
    end

    context 'when input should move from free cell to foundation' do
      before do
        sm.handle_ch('y')
      end

      subject do
        sm.handle_ch(Freecell::CharacterParser::CARRIAGE_RETURN_BYTE)
      end

      it 'returns the correct move' do
        expect(subject).to eq({ type: :move, value: [:free_cell_to_foundation, 2] })
      end
    end
  end
end
