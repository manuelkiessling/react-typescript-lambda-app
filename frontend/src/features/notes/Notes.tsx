import React, { useState, useEffect } from 'react';

import { useAppSelector, useAppDispatch } from '../../app/hooks';
import { createNote, fetchNotes, notesSlice } from './notesSlice';

export const Notes = () => {
    const reduxState = useAppSelector(state => state);
    const reduxDispatch = useAppDispatch();
    const [newNoteContent, setNewNoteContent] = useState('');

    useEffect(() => {
        reduxDispatch(fetchNotes());
    }, [reduxDispatch]);

    return (
        <div>
            {
                reduxState.notes.errorMessage !== null
                &&
                <strong>Error: {reduxState.notes.errorMessage}</strong>
            }
            <h1>Add note</h1>
            <form onSubmit={ (e) => {
                reduxDispatch(createNote({ content: newNoteContent }));
                e.preventDefault();
            }}>
                <input
                    type='text'
                    className='form-control'
                    id='create-server-title'
                    placeholder=''
                    value={newNoteContent}
                    onChange={ (e) => setNewNoteContent(e.target.value) }
                />
                <button type='submit' disabled={newNoteContent.length < 1}>
                    Add
                </button>
            </form>

            <h1>Your notes</h1>
            <p>
                <button
                    onClick={() => reduxDispatch(fetchNotes())}
                >
                    Re-fetch notes from backend
                </button>
            </p>
            <p>
                <button onClick={ () => reduxDispatch(notesSlice.actions.reset()) }>
                    Reset
                </button>
            </p>
            {reduxState.notes.notes.map(note => (
                <div>
                    <small>{note.id}</small>
                    <br/>
                    {note.content}
                    <hr/>
                </div>
            ))}
        </div>
    );
};
