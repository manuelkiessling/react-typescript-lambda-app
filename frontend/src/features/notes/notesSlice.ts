import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';

export interface Note {
  id: string,
  content: string
}

export interface NotesState {
  notes: Array<Note>,
  getNotesOperationIsRunning: boolean,
  createNoteOperationIsRunning: boolean,
}

const initialState: NotesState = {
  notes: [],
  getNotesOperationIsRunning: false,
  createNoteOperationIsRunning: false
};

export const getNotes = createAsyncThunk(
  'notes/get',
  async (arg, thunkAPI) => {
    return await fetch(
        '/api/notes/',
        {
          method: 'GET'
        })

        .then(response => {
          if (response.status === 200) {
            return response.json();
          } else {
            throw new Error(`Unexpected response from server (code ${response.status}).`);
          }
        })

        .catch(function(error) {
          console.error(error)
          return thunkAPI.rejectWithValue(error.message);
        });
  }
);

export const notesSlice = createSlice({
  name: 'notes',
  initialState,
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(getNotes.fulfilled, (state, action) => {
        state.notes = action.payload;
      });
  },
});

export default notesSlice.reducer;
