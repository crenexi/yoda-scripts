import React from 'react';
import PropTypes from 'prop-types';
import sy from './NAME.scss';

const NAME = ({ children }) => {
  const [value, setValue] = React.useState(null);

  return (
    <div className={sy.edge}>{children}</div>
  );
};

NAME.propTypes = {
  children: PropTypes.node,
};

NAME.defaultProps = {
  children: 'TODO',
};

export default NAME;
