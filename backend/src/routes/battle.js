const express = require('express');
const router = express.Router();
const battleController = require('../controllers/battleController');

/**
 * @route POST /api/battle/create
 * @desc Register battle intent in database
 * @access Public
 */
router.post('/create', battleController.createBattle);

/**
 * @route POST /api/battle/simulate
 * @desc Run deterministic simulation and sign result
 * @access Public
 */
router.post('/simulate', battleController.simulateBattle);

/**
 * @route POST /api/battle/result
 * @desc Store battle result and upload to IPFS
 * @access Public
 */
router.post('/result', battleController.storeBattleResult);

/**
 * @route GET /api/battle/:battleId
 * @desc Get battle details
 * @access Public
 */
router.get('/:battleId', battleController.getBattle);

/**
 * @route GET /api/battle/:battleId/status
 * @desc Get battle status
 * @access Public
 */
router.get('/:battleId/status', battleController.getBattleStatus);

module.exports = router;
