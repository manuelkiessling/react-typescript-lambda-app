import React, { useState } from 'react';

import { useAppSelector, useAppDispatch } from '../../app/hooks';

export function Notes() {
  const reduxState = useAppSelector(state => state);
  const reduxDispatch = useAppDispatch();
  const [newNoteContent, setNewNoteContent] = useState('');

  return (
    <div>
      <h1>Your notes</h1>
      { reduxState.notes.notes.map(note => (
          <div>
            <p>
              <small>{note.id}</small>
            </p>
            <p>
              {note.content}
            </p>
          </div>
      )) }
    </div>
  );
}
