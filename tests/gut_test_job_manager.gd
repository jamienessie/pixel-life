extends GutTest

# Tests for JobManager (M9). Uses the real autoload state — resets between tests.

func before_each() -> void:
	JobManager.quit()
	EconomyManager.set_money(0)

func test_apply_for_cashier_succeeds() -> void:
	var ok := JobManager.apply_for("cashier")
	assert_true(ok, "cashier has no education requirement")
	assert_eq(JobManager.current_job, "cashier")
	assert_eq(JobManager.career_level, 0)

func test_apply_for_doctor_requires_degree() -> void:
	var profile = CharacterProfile.new()
	profile.id = "test_player"
	profile.unlocks = {}
	GameState.active_character = profile

	var ok := JobManager.apply_for("doctor")
	assert_false(ok, "doctor blocked without degree")

	profile.unlocks = {"degree": true}
	var ok2 := JobManager.apply_for("doctor")
	assert_true(ok2, "doctor allowed once degree unlocked")

func test_shift_pays_and_increments_counter() -> void:
	JobManager.apply_for("cashier")
	JobManager.start_shift()
	assert_true(JobManager.is_in_shift())
	JobManager.end_shift()
	assert_false(JobManager.is_in_shift())
	assert_gt(EconomyManager.get_money(), 0, "shift produced money")
	assert_eq(JobManager.shifts_completed, 1)

func test_promotion_fires_after_meeting_requirements() -> void:
	JobManager.apply_for("cashier")
	for i in range(8):
		JobManager.start_shift()
		# Force a high performance to ensure promotion is reachable.
		JobManager.end_shift(60, 0.8)
	assert_gte(JobManager.career_level, 1, "promoted at least once after 8 high-perf shifts")

func test_quit_resets_state() -> void:
	JobManager.apply_for("cashier")
	JobManager.start_shift()
	JobManager.end_shift(60, 0.9)
	JobManager.quit()
	assert_eq(JobManager.current_job, "")
	assert_eq(JobManager.career_level, 0)
	assert_eq(JobManager.shifts_completed, 0)

func test_serialize_roundtrip() -> void:
	JobManager.apply_for("painter")
	JobManager.start_shift()
	JobManager.end_shift(70, 0.65)
	var snapshot := JobManager.serialize()
	JobManager.quit()
	JobManager.deserialize(snapshot)
	assert_eq(JobManager.current_job, "painter")
	assert_eq(JobManager.shifts_completed, 1)
