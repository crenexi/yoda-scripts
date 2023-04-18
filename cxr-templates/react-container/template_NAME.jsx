import React from 'react';
import PropTypes from 'prop-types';
import styles from './NAME.scss';

const NAME = ({ children }) => (
  <div className={styles.frame}>{children}</div>
);

NAME.propTypes = {
  children: PropTypes.node,
};

NAME.defaultProps = {
  children: 'TODO',
};

export default NAME;
