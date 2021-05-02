import { createAsyncThunk, createSlice } from '@reduxjs/toolkit';

export interface Note {
    readonly id: string,
    readonly content: string
}

export interface NotesState {
    readonly notes: Note[],
    readonly errorMessage: null | string
}

const initialState: NotesState = {
    notes: [],
    errorMessage: null
};

export const createNote = createAsyncThunk<Note, { readonly content: string }, { rejectValue: { readonly errorMessage: string, readonly note: Note } }>(
    'notes/create',

    async (arg, thunkAPI) => {
        const note: Note = { id: Math.random().toString(), content: arg.content };
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
                return thunkAPI.rejectWithValue({ errorMessage: error.message, note });
            });
    }
);


export const fetchNotes = createAsyncThunk<Note[], void, { rejectValue: string }>(
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
    reducers: {
        reset: () => initialState
    },
    extraReducers: (builder) => {
        builder
            .addCase(createNote.fulfilled, (state, action) => {
                state.notes.unshift(action.payload);
                state.errorMessage = null;
            });

        builder
            .addCase(createNote.rejected, (state, action) => {
                if (action.payload !== undefined) {
                    state.notes.unshift(action.payload.note);
                    state.errorMessage = action.payload.errorMessage;
                }
            });


        builder
            .addCase(fetchNotes.fulfilled, (state, action) => {
                state.notes = action.payload;
            });

        builder
            .addCase(fetchNotes.rejected, (state, action) => {
                state.errorMessage = action.payload ?? null;
            });
    },
});

export default notesSlice.reducer;
