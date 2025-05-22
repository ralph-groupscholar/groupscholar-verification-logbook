INSERT INTO gsvl.verification_checks
  (id, scholar_name, scholar_id, check_type, status, notes, performed_by, performed_at)
VALUES
  ('9d3f0d0d-1b1a-4f8e-bd07-0c0b93b1a0d1', 'Avery Johnson', 'GS-102', 'Residency', 'verified',
    'Submitted updated lease and utility bill.', 'Ralph', NOW() - INTERVAL '3 days'),
  ('2c9a7a42-5d68-44b6-9cd3-5d2a6d8b7bb1', 'Maya Chen', 'GS-207', 'Income', 'pending',
    'Awaiting last pay stub from employer.', 'Jordan', NOW() - INTERVAL '5 days'),
  ('8f0b5c8a-5b6c-4f4e-87b8-2c9a1a4a9a72', 'Luis Martinez', 'GS-188', 'Enrollment', 'verified',
    'Registrar letter confirms enrollment for spring.', 'Priya', NOW() - INTERVAL '8 days'),
  ('1f5a8b7c-0cdd-4b30-8d2c-4d7a5b68f2f3', 'Sofia Patel', 'GS-215', 'Identity', 'failed',
    'ID scan expired, requested updated document.', 'Ralph', NOW() - INTERVAL '12 days'),
  ('6a2c9e7b-2a10-4c1c-bb5f-6a72d0b6b2a9', 'Noah Williams', 'GS-164', 'Residency', 'verified',
    'Dorm confirmation received.', 'Amira', NOW() - INTERVAL '15 days');
