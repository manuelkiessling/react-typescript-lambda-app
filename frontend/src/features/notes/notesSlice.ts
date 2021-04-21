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

export const createNote = createAsyncThunk<Note, { content: string }>(
    'notes/create',
    async (arg, thunkAPI) => {

        const note: Note = {id: Math.random().toString(), content: arg.content};

        return await fetch(
            '/api/notes/',
            {
                method: 'POST',
                body: JSON.stringify(note)
            })

            .then(response => {
                if (response.status === 201) {
                    return note;
                } else {
                    throw new Error(`Unexpected response from server (code ${response.status}).`);
                }
            })

            .catch(function (error) {
                console.error(error);
                return thunkAPI.rejectWithValue(error.message);
            });
    }
);


export const fetchNotes = createAsyncThunk(
    'notes/fetch',
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

            .catch(function (error) {
                console.error(error);
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
            .addCase(createNote.fulfilled, (state, action) => {
                state.notes.unshift(action.payload);
            });

        builder
            .addCase(fetchNotes.fulfilled, (state, action) => {
                state.notes = action.payload;
            });
    },
});

export default notesSlice.reducer;
