import React from 'react';
import PropTypes from 'prop-types';
import useDataHard from '@hooks/use-data-hard';
import styles from './NAME.scss';

const NAME = ({ children }) => {
  const hard = useDataHard();

  return (
    <div className={styles.frame}>{children}</div>
  );
};

NAME.propTypes = {
  children: PropTypes.node,
};

NAME.defaultProps = {
  children: 'TODO',
};

export default NAME;
