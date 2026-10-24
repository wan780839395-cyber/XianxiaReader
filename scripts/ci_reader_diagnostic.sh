#!/bin/bash
# Selected macOS diagnostics only. This script never builds or packages a device IPA.
# The default full ios-build.yml/ci_ios.sh pipeline remains the delivery gate.
set -euo pipefail
cd "$(dirname "$0")/.."
selection="${1:?Choose native-input, fonts, panels, recovery, settings, settings-ui, webkit-loading, webkit-close, paged-restore reader-session or reader-ready-ui, background-ui, continuous-rotation}"
case "$selection" in
  continuous-resize-pair)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView)
    ;;
  continuous-resize-smoke)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView)
    export TEST_RUNNER_XIANXIA_VIEWPORT_FIXTURE=smoke
    echo "VIEWPORT_FIXTURE_REQUEST mode=smoke expectedNativeCases=1"
    ;;
  continuous-resize)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView)
    ;;
  initialization-close)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews
    )
    ;;
  position-acceptance)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testFailedFreshSaveKeepsStoredProgressAndRetryIsVisible
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateBookmarkFailureAfterCloseCannotShowError
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateChapterNavigationCannotHideReopenedReadersMenu
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLatePositionAfterCloseIsNotPersisted
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateSaveCaptureCannotOverwriteProgressAfterCloseAndReopen
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testPositionBurstPublishesOnlyProgressAndPreservesLatestFullLocator
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnCaptureCloseReopenLateResultCannotNavigateOrClearNewRequest
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnCaptureFailureAndCancellationNeverPublishOrNavigate
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnPointFailureRetryAndClosePreserveCurrentProgressWithoutPersistingOrigin
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnPointRetainsFirstFullAnchorAcrossContentsBookmarkSearchAndStay
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testSaveNowUsesFreshFullAnchorInsteadOfDelayedCachedChapterHead
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testSaveNowWaitsForReflowSamplingAndKeepsTheCompleteLocator
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testSettingsCommitDoesNotSampleCoveredPageAndFreshPositionFailureStillPreservesProgress
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testSupersededAndCancelledSaveCapturesCannotOverwriteNewerProgress
      -only-testing:XianxiaReaderTests/ReaderProgressTests/testSummaryChangesDoNotDiscardOpaquePositionOrPublishEquivalentDisplay
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testPagedNativeLoadDoesNotWaitForAnimationFrameBridge
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSameWidthBodyResizeDoesNotOverwritePendingPagedWord
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderTests/TXTReadingTests/testFreshReturnCaptureKeepsTXTByteUTF16AnchorAcrossJumpAndStaticReopen
    )
    ;;
  search-isolation)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnPointRetainsFirstFullAnchorAcrossContentsBookmarkSearchAndStay
      -only-testing:XianxiaReaderTests/ReaderSearchFieldTests/testNativeQueryFieldKeepsChineseCompositionAndCaretAcrossThemeThenClears
      -only-testing:XianxiaReaderTests/ReaderSearchViewModelTests/testEmptyAndOversizedQueryNeverStartEngineSearch
      -only-testing:XianxiaReaderTests/ReaderSearchViewModelTests/testLatePageCannotReplaceNewQueryResults
      -only-testing:XianxiaReaderTests/ReaderSearchViewModelTests/testLateStartedSessionIsCancelledAfterQueryChanges
      -only-testing:XianxiaReaderTests/ReaderSearchViewModelTests/testLoadMoreIsExplicitAndResultsStopAtVisibleLimit
      -only-testing:XianxiaReaderTests/ReaderSearchViewModelTests/testSelectionDelegatesOpaquePositionAndReportsNavigationFailure
      -only-testing:XianxiaReaderTests/ReadiumSearchTests/testBatchSizeSnippetBoundsAndEndPreserveCSSLocator
      -only-testing:XianxiaReaderTests/ReadiumSearchTests/testCombiningCharactersEmojiAndInlineSegmentBoundaries
      -only-testing:XianxiaReaderTests/ReadiumSearchTests/testConcurrentNextRejectedAndCancelledSessionRejectsLatePage
      -only-testing:XianxiaReaderTests/ReadiumSearchTests/testContentReadFailureIsNotReportedAsNoMatches
      -only-testing:XianxiaReaderTests/ReadiumSearchTests/testLiteralQueryCaseInsensitiveAndNoCrossParagraphMatch
      -only-testing:XianxiaReaderTests/ReadiumSearchTests/testRealEPUB2AndEPUB3ChineseSearchPositions
    )
    ;;
  import-isolation)
    cases=(
      -only-testing:XianxiaReaderTests/BookDuplicateTests/testCancelledDuplicateImportDoesNotRemoveAlreadyCommittedBook
      -only-testing:XianxiaReaderTests/BookDuplicateTests/testDuplicateTrashFeedbackRestoresExplicitlyAndKeepsSavedProgressAfterRestart
      -only-testing:XianxiaReaderTests/BookDuplicateTests/testMixedBatchCountsDuplicatesNewBooksAndBadFilesTruthfully
      -only-testing:XianxiaReaderTests/BookDuplicateTests/testRealEPUBAndTXTRenamedCopiesKeepUUIDCoverAndFullReadingHistory
      -only-testing:XianxiaReaderTests/DocumentImportTests/testBroadPickerImportsTXTAndUppercaseEPUBRejectsUnsupportedFileInSameBatch
      -only-testing:XianxiaReaderTests/DocumentImportTests/testBundledSamplesImportWithoutFileProvider
      -only-testing:XianxiaReaderTests/DocumentImportTests/testEmptyBatchReportsErrorAndCanRetryWithSamples
      -only-testing:XianxiaReaderTests/DocumentImportTests/testFirstEPUBSelectionThroughNativeSheetImportsWithoutRetry
      -only-testing:XianxiaReaderTests/DocumentImportTests/testFirstFileSelectionWithExistingShelfAndEncodingSheetRoundTrip
      -only-testing:XianxiaReaderTests/DocumentImportTests/testFirstTXTSelectionThroughNativeSheetImportsWithoutRetry
      -only-testing:XianxiaReaderTests/DocumentImportTests/testNativeSheetCancellationAndEmptySelectionCanRetryWithoutStaleFiles
      -only-testing:XianxiaReaderTests/EPUBIntegrationTests/testCorruptEPUBImportRollsBackFilesAndDatabase
      -only-testing:XianxiaReaderTests/EPUBIntegrationTests/testEPUB2AndEPUB3MetadataAndNavigationIndex
      -only-testing:XianxiaReaderTests/EPUBIntegrationTests/testRealImportPersistsBookAndCachedTOC
    )
    ;;
  library-isolation)
    cases=(
      -only-testing:XianxiaReaderTests/LibraryBoundaryTests
      -only-testing:XianxiaReaderTests/LibraryTests
      -only-testing:XianxiaReaderTests/LibraryRemovalTests
      -only-testing:XianxiaReaderTests/BookCoverTests
    )
    ;;
  session-owner-baseline)
    cases=(-only-testing:XianxiaReaderTests/ReaderLifecycleTests/testClosedAndReopenedSessionRejectsCapturedOldCallbacks)
    ;;
  session-isolation)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testClosedAndReopenedSessionRejectsCapturedOldCallbacks
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testClosedSessionRejectsEventsAndPreservesFinalEmittedPosition
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testPositionBurstPublishesOnlyProgressAndPreservesLatestFullLocator
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testCloseDuringOpenCannotReturnReaderToReadyState
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testFailedOpenCanRetryAndBecomeReady
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLatePositionAfterCloseIsNotPersisted
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testOldSettingsFailureCannotPublishIntoSameModelReopenedSession
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateSaveCaptureCannotOverwriteProgressAfterCloseAndReopen
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnCaptureCloseReopenLateResultCannotNavigateOrClearNewRequest
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateChapterNavigationCannotHideReopenedReadersMenu
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateBookmarkFailureAfterCloseCannotShowError
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testInteractionRestoresSerialEditsAndLateGesturesCannotHideMenuAfterClose
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testAutomaticScrollExplicitStartSpeedPersistenceBackgroundPauseAndStaticReopen
    )
    ;;
  continuous-return)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes)
    ;;
  epub-ready-baseline)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testPagedNativeLoadDoesNotWaitForAnimationFrameBridge)
    ;;
  epub-ready-patched)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testPagedNativeLoadDoesNotWaitForAnimationFrameBridge
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousNativeLoadDoesNotWaitForAnimationFrameBridge
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSameWidthBodyResizeDoesNotOverwritePendingPagedWord
    )
    ;;
  position-isolation)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testPositionBurstPublishesOnlyProgressAndPreservesLatestFullLocator
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testSettingsCommitDoesNotSampleCoveredPageAndFreshPositionFailureStillPreservesProgress
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testSaveNowUsesFreshFullAnchorInsteadOfDelayedCachedChapterHead
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testSaveNowWaitsForReflowSamplingAndKeepsTheCompleteLocator
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateSaveCaptureCannotOverwriteProgressAfterCloseAndReopen
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testFailedFreshSaveKeepsStoredProgressAndRetryIsVisible
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testSupersededAndCancelledSaveCapturesCannotOverwriteNewerProgress
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLatePositionAfterCloseIsNotPersisted
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnPointRetainsFirstFullAnchorAcrossContentsBookmarkSearchAndStay
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnPointFailureRetryAndClosePreserveCurrentProgressWithoutPersistingOrigin
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnCaptureCloseReopenLateResultCannotNavigateOrClearNewRequest
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testReturnCaptureFailureAndCancellationNeverPublishOrNavigate
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateChapterNavigationCannotHideReopenedReadersMenu
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests/testLateBookmarkFailureAfterCloseCannotShowError
      -only-testing:XianxiaReaderTests/ReaderProgressTests/testSummaryChangesDoNotDiscardOpaquePositionOrPublishEquivalentDisplay
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSameWidthBodyResizeDoesNotOverwritePendingPagedWord
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/TXTReadingTests/testFreshReturnCaptureKeepsTXTByteUTF16AnchorAcrossJumpAndStaticReopen
    )
    ;;
  paged-font)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
    )
    ;;
  position-control-baseline)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes)
    ;;
  paged-resize-control)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testSameWidthBodyResizeDoesNotOverwritePendingPagedWord)
    ;;
  paged-font-acceptance)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testPagedReopenRestoresFirstCharacterOfLongParagraph
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView
      -only-testing:XianxiaReaderTests/TXTReadingTests/testFreshReturnCaptureKeepsTXTByteUTF16AnchorAcrossJumpAndStaticReopen
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testClosingDuringDelayedFontReadyCannotNavigateOrNotifyNewReader
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSameWidthBodyResizeDoesNotOverwritePendingPagedWord
    )
    ;;
  position-fix)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testPagedReopenRestoresFirstCharacterOfLongParagraph
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testFreshReturnCaptureRestoresNonzeroEPUBTextInPagedAndContinuousModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView
      -only-testing:XianxiaReaderTests/TXTReadingTests/testFreshReturnCaptureKeepsTXTByteUTF16AnchorAcrossJumpAndStaticReopen
    )
    ;;
  position-observation)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes)
    ;;
  txt-initial-load)
    cases=(-only-testing:XianxiaReaderTests/TXTReadingTests/testFreshReturnCaptureKeepsTXTByteUTF16AnchorAcrossJumpAndStaticReopen)
    ;;
  paged-restore)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testPagedReopenRestoresFirstCharacterOfLongParagraph)
    ;;
  initialization-pending)
    cases=(-only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord)
    ;;
  preferences-idempotency)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testRepeatedAppliedPreferencesKeepFreshCaptureAvailableAndCancelQueuedChange
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
    )
    ;;
  continuous-rotation)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousViewportResizeKeepsOriginalWordAndLiveWebView
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testScrollingCanMoveToNextResourceAndTOCFragment
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSixFontsAndExtendedTypographyKeepFreshNonzeroContinuousAnchor
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testUnsafeEdgesRemainCoveredDuringSlowScrollThemeAndRotation
    )
    ;;
  background-ui)
    cases=(-only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testAutomaticSlowScrollTouchBackgroundDarkControlsSpeedAndStaticRelaunch)
    ;;
  reader-ready-ui)
    cases=(
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testPaperProbeIncludesSurroundingPaperAndRejectsWrongTheme
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testUnsafeEdgesRemainCoveredDuringSlowScrollThemeAndRotation
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testAutomaticSlowScrollTouchBackgroundDarkControlsSpeedAndStaticRelaunch
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testNativeMenuLayoutGroupsPublisherRulesAndRelaunch
    )
    ;;
  reader-session)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests
      -only-testing:XianxiaReaderTests/ReaderSettingsPersistenceTests
      -only-testing:XianxiaReaderTests/ReaderRenderingTests
      -only-testing:XianxiaReaderTests/ZWebKitLoadingControlTests
    )
    ;;
  webkit-close)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testClosingDuringInitializationDisconnectsPagedAndContinuousWebViews
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImmediateCloseCannotMountLatePaginationOrWebViews
    )
    ;;
  webkit-loading)
    cases=(
      -only-testing:XianxiaReaderTests/ZWebKitLoadingControlTests
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testAutomaticScrollRealDisplayLinkPauseLateFrameFullLocatorAndReopen
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSixFontsAndExtendedTypographyKeepFreshNonzeroContinuousAnchor
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testTallCoverUsesWholeViewportInPaginatedAndScrollingModes
    )
    ;;
  settings-ui)
    cases=(
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testTouchExtentComparisonKeeps44PointMinimumAndRejectsRealShortfalls
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testProgressAndHeaderBackdropKeepMenuGesturesAndChapterUpdates
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testUnsafeEdgesRemainCoveredDuringSlowScrollThemeAndRotation
      -only-testing:XianxiaReaderUITests/ReadingFontUITests/testBundledChineseFontCardsSelectPersistAndSwitchInDarkMode
      -only-testing:XianxiaReaderUITests/ReadingFontUITests/testCompactSettingsKeepFontRowsStableAndLayoutWithinOneScreen
      -only-testing:XianxiaReaderUITests/ReadingFontUITests/testNativeFontSelectionPickerCancelDarkResetAndRelaunch
    )
    ;;
  settings)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderSettingsPersistenceTests
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests
    )
    ;;
  native-input)
    cases=(-only-testing:XianxiaReaderTests/ReaderSearchFieldTests)
    ;;
  font-isolation)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderFontCoordinatorTests
      -only-testing:XianxiaReaderTests/ReadingFontTests
      -only-testing:XianxiaReaderTests/ReaderSettingsPersistenceTests
      -only-testing:XianxiaReaderTests/ReaderLifecycleTests
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderUITests/ReadingFontUITests/testNativeFontSelectionPickerCancelDarkResetAndRelaunch
    )
    ;;
  fonts)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
    )
    ;;
  recovery)
    cases=(
      -only-testing:XianxiaReaderTests/TXTReadingTests/testTXTChineseAppearanceAndNonzeroUTF16AnchorSurviveTypographyAndReopen
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderUITests/LibraryInteractionUITests/testCoverEditorNativeFilesCancelDefaultSaveAndReopen
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testNativeMenuLayoutGroupsPublisherRulesAndRelaunch
      -only-testing:XianxiaReaderTests/ReaderSurfaceTests
      -only-testing:XianxiaReaderTests/ReadingExperienceTests/testReaderPresentationThemeNeverChangesShelfOrWindowAndRestoresLocalOverride
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testContinuousBoundaryShowsTwoResourcesAndScrollsBack
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testProgressAndHeaderBackdropKeepMenuGesturesAndChapterUpdates
      -only-testing:XianxiaReaderUITests/ReadingExperienceUITests/testFontCollectionGridSearchAndOptInLayoutPresetsPreserveSelection
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testUnsafeEdgesRemainCoveredDuringSlowScrollThemeAndRotation
    )
    ;;
  panels)
    cases=(
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testImportedFontReallyLoadsAndRebuildKeepsNonzeroEPUBAnchorInBothModes
      -only-testing:XianxiaReaderTests/ReaderRenderingTests/testSelectingAnotherFontDuringHiddenReflowKeepsTheOriginalPagedWord
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testNativeMenuLayoutGroupsPublisherRulesAndRelaunch
      -only-testing:XianxiaReaderTests/ReadingExperienceTests
      -only-testing:XianxiaReaderTests/ReaderSearchFieldTests
      -only-testing:XianxiaReaderTests/ReadingFontTests/testExternalFontBrowsingDoesNotRebuildUntilExplicitSelectionAndKeepsFullAnchor
      -only-testing:XianxiaReaderUITests/ReadingExperienceUITests
      -only-testing:XianxiaReaderUITests/ReadingFontUITests
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testReadingPanelsFollowFiveThemesAndKeepNativeHitRegions
      -only-testing:XianxiaReaderUITests/ReaderInterfaceUITests/testThemedBookmarkSwipePersistsAndSearchClearDoesNotReuseResults
    )
    ;;
  *) echo "Invalid diagnostic selection" >&2; exit 2 ;;
esac
mkdir -p build/logs .cache
test -d "${DEVELOPER_DIR:?Select Xcode 16.4}/Platforms/iPhoneOS.platform"
xcodebuild -version | tee build/build-environment.txt
swift --version | tee -a build/build-environment.txt
sw_vers | tee -a build/build-environment.txt
if [[ "$selection" == 'continuous-resize-pair' ]]; then
  python3 scripts/ci_viewport_pair.py prepare
fi
if [[ ! -d .cache/XcodeGen ]]; then
  git clone --depth 1 --branch 2.46.0 https://github.com/yonaskolb/XcodeGen.git .cache/XcodeGen
fi
test "$(git -C .cache/XcodeGen describe --tags --exact-match)" = "2.46.0"
swift run --package-path .cache/XcodeGen --configuration release xcodegen generate --spec "$PWD/project.yml"
mkdir -p XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
cp Package.resolved XianxiaReader.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
python3 scripts/verify_readium_lock.py Package.resolved
cp Package.resolved build/Package.resolved
xcodebuild -resolvePackageDependencies -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages"
xcrun simctl list devices available --json > build/devices.json
SIMULATOR_ID=$(python3 scripts/select_simulator.py build/devices.json)
if [[ "$selection" == 'continuous-resize-pair' || "$selection" == 'initialization-close' || "$selection" == 'position-isolation' || "$selection" == 'position-acceptance' || "$selection" == 'epub-ready-baseline' || "$selection" == 'epub-ready-patched' || "$selection" == 'continuous-return' || "$selection" == 'continuous-resize' || "$selection" == 'continuous-resize-smoke' || "$selection" == 'session-owner-baseline' || "$selection" == 'session-isolation' || "$selection" == 'import-isolation' || "$selection" == 'search-isolation' ]]; then
  # Catch new product/target wiring errors before waiting for simulator migration.
  # Compile the exact selected destination; the original test action below keeps
  # its cases, assertions and budgets, reusing these ordinary build products.
  xcodebuild build-for-testing -project XianxiaReader.xcodeproj -scheme XianxiaReader \
    -onlyUsePackageVersionsFromResolvedFile \
    -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
    -derivedDataPath "$PWD/build/DerivedData" \
    -clonedSourcePackagesDirPath "$PWD/build/SourcePackages" \
    -resultBundlePath "$PWD/build/PositionBuild.xcresult" \
    "${cases[@]}" CODE_SIGNING_ALLOWED=NO
fi
if [[ "$selection" == 'continuous-resize-pair' ]]; then
  # Only this route reuses the exact built products in two fresh test processes.
  exec python3 scripts/ci_viewport_pair.py run "$SIMULATOR_ID"
fi
xcrun simctl bootstatus "$SIMULATOR_ID" -b
if [[ "$selection" == 'panels' || "$selection" == 'recovery' || "$selection" == 'settings-ui' || "$selection" == 'reader-ready-ui' || "$selection" == 'background-ui' || "$selection" == 'continuous-rotation' || "$selection" == 'initialization-pending' ]]; then xcrun simctl ui "$SIMULATOR_ID" appearance dark; fi
if ps -axo pid,ppid,state,rss,comm > build/logs/processes-before-tests.log 2>&1; then :
else echo "Additional pre-test process context unavailable; original tests still run"; fi
resource_monitor_pid=''
stop_resource_monitor() {
  if [[ -n "$resource_monitor_pid" ]]; then
    if kill -TERM "$resource_monitor_pid"; then
      if wait "$resource_monitor_pid"; then :
      else echo "Best-effort resource monitor exit: $?; test exit remains authoritative"; fi
    else
      if wait "$resource_monitor_pid"; then :
      else echo "Best-effort resource monitor already ended: $?; test exit remains authoritative"; fi
    fi
    resource_monitor_pid=''
  fi
}
if [[ "$selection" == 'reader-session' || "$selection" == 'fonts' || "$selection" == 'initialization-pending' ]]; then
  python3 scripts/capture_native_resources.py > build/logs/native-resources.jsonl 2>&1 &
  resource_monitor_pid=$!
  trap stop_resource_monitor EXIT
fi
test_status=0
if xcodebuild test -project XianxiaReader.xcodeproj -scheme XianxiaReader \
  -onlyUsePackageVersionsFromResolvedFile \
  -configuration Debug -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -derivedDataPath "$PWD/build/DerivedData" \
  -clonedSourcePackagesDirPath "$PWD/build/SourcePackages" \
  -resultBundlePath "$PWD/build/DiagnosticTests.xcresult" \
  "${cases[@]}" CODE_SIGNING_ALLOWED=NO; then test_status=0; else test_status=$?; fi
stop_resource_monitor
summary_status=0
if xcrun xcresulttool get test-results summary --path build/DiagnosticTests.xcresult > build/test-results-summary.json; then
  summary_status=0
else summary_status=$?; fi
export_status=0
if xcrun xcresulttool export attachments --path build/DiagnosticTests.xcresult --output-path build/ReaderSnapshots; then
  export_status=0
else export_status=$?; fi
# Best-effort, bounded service context; no command arguments or book text.
# Missing/slow diagnostic tools are recorded, preserving the actual test exit.
if python3 - "$SIMULATOR_ID" <<'XR_CONTEXT'
from pathlib import Path
import json, subprocess, sys
folder=Path("build/logs");folder.mkdir(parents=True,exist_ok=True);records=[]
commands=[("processes-after-tests",["ps","-axo","pid,ppid,state,rss,comm"],10),
          ("reading-lifecycle",["xcrun","simctl","spawn",sys.argv[1],"log","show","--last","20m","--info","--style","compact","--predicate",'eventMessage BEGINSWITH "XRReadingLifecycle" OR eventMessage BEGINSWITH "XRPresentation"'],20),
          ("document-services",["xcrun","simctl","spawn",sys.argv[1],"log","show","--last","10m","--style","compact","--predicate",'subsystem CONTAINS "DocumentManager" OR subsystem CONTAINS "FileProvider"'],20)]
for name,command,seconds in commands:
    try:
        result=subprocess.run(command,capture_output=True,timeout=seconds)
        (folder/(name+".log")).write_bytes(result.stdout+result.stderr)
        records.append(dict(name=name,exit=result.returncode,timeout=False))
    except subprocess.TimeoutExpired as error:
        (folder/(name+".log")).write_bytes((error.stdout or b"")+(error.stderr or b""))
        records.append(dict(name=name,timeout=True,error=str(error)))
    except OSError as error:
        (folder/(name+".log")).write_text(str(error))
        records.append(dict(name=name,timeout=False,error=str(error)))
(folder/"additional-context.json").write_text(json.dumps(dict(bestEffort=True,records=records),indent=2))
print("Additional simulated service context recorded; original test/build exits preserved")
XR_CONTEXT
then echo "Additional context command exit: 0"
else context_status=$?; echo "Additional context command exit: $context_status; original test/build exits preserved"; fi
echo "DIAGNOSTIC ONLY: $selection; test=$test_status summary=$summary_status export=$export_status; no device Release or IPA"
if (( test_status != 0 )); then exit "$test_status"; fi
if (( summary_status != 0 )); then exit "$summary_status"; fi
if (( export_status != 0 )); then exit "$export_status"; fi
